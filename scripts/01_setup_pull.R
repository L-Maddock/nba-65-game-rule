# =============================================================================
# 01_setup_and_pull.R
#
# NBA 65-game rule: project setup and first data pull
#
# What this script does
#   0. Creates the project directory tree under PROJECT_ROOT
#   1. Pulls player-game box scores 2013-14 to 2025-26 (hoopR, no scraping)
#   2. Pulls the schedule with broadcast fields (hoopR, no scraping)
#   3. Scrapes the small Basketball-Reference tables needed for the star
#      lookup (All-NBA, All-Star rosters, MVP/DPOY voting), politely and cached
#   4. Builds the lagged "star" flag (PPP definition) and contention proxy
#   5. Builds the player-season table with qualifying games under the 65-game rule
#   6. Produces the go/no-go figure: games-played distribution, stars, pre vs post
#
# Stages end with checks that stop the script if something is off.
# Rerunning is cheap: raw pulls and scraped pages are cached on disk.
# =============================================================================


# -----------------------------------------------------------------------------
# 0. SETUP: PACKAGES, PATHS, DIRECTORY TREE
# -----------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
  library(janitor)
  library(hoopR)
  library(rvest)
  library(stringi)
})

PROJECT_ROOT <- "/Users/maddockl/nba-65-game-rule"

DIRS <- c(
  "data/raw",            # untouched pulls: hoopR rds, BBR html
  "data/raw/bbr",        # cached Basketball-Reference pages
  "data/intermediate",   # cleaned tables, one per source
  "data/derived",        # analysis panels
  "assets",              # hand-coded lookups: name overrides, contract stakes, rule dates
  "results/figures",
  "results/tables",
  "scripts",
  "docs",
  "logs"
)

for (d in DIRS) dir.create(file.path(PROJECT_ROOT, d), recursive = TRUE, showWarnings = FALSE)
setwd(PROJECT_ROOT)

# --- Sample definition -------------------------------------------------------
# hoopR seasons are END years: 2016 = 2015-16.
SEASONS       <- 2014:2026
COVID_SEASONS <- c(2020, 2021)         # kept in raw data, flagged, dropped at estimation
POST_SEASONS  <- 2024:2026             # 65-game rule in force
RULE_GAMES    <- 65
RULE_MIN      <- 20                    # minutes for a game to count
RULE_MIN_LOW  <- 15                    # up to two games of 15-19 minutes also count
RULE_LOW_ALLOW <- 2

# --- Run flags ---------------------------------------------------------------
REFRESH_HOOPR <- FALSE                 # TRUE re-downloads box scores and schedule
BBR_SLEEP_SEC <- 20                     # Sports-Reference limit is ~20 req/min; stay well under

# --- Helpers -----------------------------------------------------------------
stage <- function(txt) cat("\n", strrep("=", 78), "\n", txt, "\n", strrep("=", 78), "\n", sep = "")
check <- function(cond, msg) {
  if (!isTRUE(cond)) stop("CHECK FAILED: ", msg, call. = FALSE)
  cat("  ok:", msg, "\n")
}
norm_name <- function(x) {
  x %>%
    stri_trans_general("Latin-ASCII") %>%
    str_to_lower() %>%
    str_remove_all("[.'’,]") %>%
    str_remove_all("\\b(jr|sr|ii|iii|iv)\\b") %>%
    str_squish()
}

# Write a short README so the tree is self-describing
writeLines(c(
  "# NBA 65-game rule project",
  "",
  "data/raw          untouched pulls (hoopR rds, Basketball-Reference html)",
  "data/intermediate cleaned single-source tables",
  "data/derived      analysis panels (player-game, player-season)",
  "assets            hand-coded lookups (name overrides, contract stakes)",
  "results           figures and tables",
  "scripts           numbered scripts, run in order",
  "logs              run logs",
  "",
  "Seasons are indexed by END year (2016 = 2015-16). COVID seasons 2020, 2021 flagged.",
  "65-game rule in force from season 2024 (2023-24) onward."
), file.path(PROJECT_ROOT, "docs", "README.md"))

cat("  project root:", PROJECT_ROOT, "\n")


# -----------------------------------------------------------------------------
# 1. PLAYER-GAME BOX SCORES (hoopR, pre-built files, no live scraping)
# -----------------------------------------------------------------------------
stage("STAGE 1: player-game box scores")

box_path <- "data/raw/player_box_raw.rds"
if (REFRESH_HOOPR || !file.exists(box_path)) {
  cat("  downloading player box scores for seasons", min(SEASONS), "-", max(SEASONS), "\n")
  box_raw <- load_nba_player_box(seasons = SEASONS)
  write_rds(box_raw, box_path)
} else {
  box_raw <- read_rds(box_path)
}

cat("  columns:", paste(names(box_raw), collapse = ", "), "\n")

need_box <- c("game_id", "season", "season_type", "game_date", "athlete_id", "athlete_display_name",
              "team_id", "team_abbreviation", "minutes", "did_not_play", "reason", "starter", "active")
check(all(need_box %in% names(box_raw)),
      paste("box score has required columns; missing:", paste(setdiff(need_box, names(box_raw)), collapse = ", ")))

player_box <- box_raw %>%
  filter(season_type == 2) %>%                        # regular season only
  transmute(
    game_id      = as.character(game_id),
    season       = as.integer(season),
    game_date    = as_date(game_date),
    athlete_id   = as.character(athlete_id),
    athlete_name = athlete_display_name,
    team_id      = as.character(team_id),
    team_abbr    = team_abbreviation,
    minutes      = suppressWarnings(as.numeric(minutes)),
    did_not_play = as.logical(did_not_play),
    reason       = as.character(reason),
    starter      = as.logical(starter),
    active       = as.logical(active)
  ) %>%
  mutate(
    minutes   = replace_na(minutes, 0),
    played    = !did_not_play & minutes > 0,
    covid     = season %in% COVID_SEASONS,
    post_rule = season %in% POST_SEASONS
  ) %>%
  distinct(game_id, athlete_id, .keep_all = TRUE)

# --- Checks
games_per_season <- player_box %>% distinct(season, game_id) %>% count(season)
cat("\n  Regular-season games per season (1230 normal; 2020 ~1059; 2021 1080):\n"); print(games_per_season, n = Inf)
check(all(games_per_season$n[!games_per_season$season %in% COVID_SEASONS] >= 1150),
      "non-COVID seasons have >= 1150 games (partial pull otherwise)")

roster_rows <- player_box %>% count(game_id, team_id, name = "n_rows") %>% summarise(lo = min(n_rows), hi = max(n_rows), med = median(n_rows))
cat("  rows per team-game: min", roster_rows$lo, "median", roster_rows$med, "max", roster_rows$hi, "\n")
check(roster_rows$med >= 12, "median roster rows per team-game >= 12 (DNP players are included)")

reason_cov <- player_box %>% filter(did_not_play) %>% group_by(season) %>%
  summarise(share_reason = round(mean(!is.na(reason) & reason != ""), 2), .groups = "drop")
cat("\n  Share of DNP rows with a reason string, by season (must be stable to use reasons):\n"); print(reason_cov, n = Inf)

cat("\n  Most common DNP reason strings:\n")
player_box %>% filter(did_not_play) %>% count(reason, sort = TRUE) %>% head(15) %>% print()

write_rds(player_box, "data/intermediate/player_box.rds")


# -----------------------------------------------------------------------------
# 2. SCHEDULE WITH BROADCAST FIELDS (hoopR)
# -----------------------------------------------------------------------------
stage("STAGE 2: schedule")

sched_path <- "data/raw/schedule_raw.rds"
if (REFRESH_HOOPR || !file.exists(sched_path)) {
  sched_raw <- load_nba_schedule(seasons = SEASONS)
  write_rds(sched_raw, sched_path)
} else {
  sched_raw <- read_rds(sched_path)
}

bcast_cols <- names(sched_raw)[str_detect(names(sched_raw), regex("broadcast", ignore_case = TRUE))]
cat("  broadcast-related columns:", if (length(bcast_cols)) paste(bcast_cols, collapse = ", ") else "NONE FOUND", "\n")

schedule <- sched_raw %>%
  filter(season_type == 2) %>%
  transmute(game_id = as.character(game_id), season = as.integer(season), game_date = as_date(ymd_hms(date, quiet = TRUE)),
            home_id = as.character(home_id), away_id = as.character(away_id),
            broadcast = if (length(bcast_cols)) as.character(.data[[bcast_cols[1]]]) else NA_character_) %>%
  mutate(national_tv = str_detect(coalesce(broadcast, ""), regex("ESPN|ABC|TNT|NBA TV|Prime|Peacock|NBC", ignore_case = TRUE)))

check(nrow(schedule) > 0, "schedule pulled")
check(mean(player_box$game_id %in% schedule$game_id) > 0.98, "box-score game_ids match schedule game_ids")
if (length(bcast_cols) == 0) cat("  NOTE: no broadcast column; national-TV flag will need the NBA static schedule JSON later\n")

write_rds(schedule, "data/intermediate/schedule.rds")


# -----------------------------------------------------------------------------
# 3. BASKETBALL-REFERENCE LOOKUPS (polite, cached)
# -----------------------------------------------------------------------------
stage("STAGE 3: Basketball-Reference All-NBA, All-Star, award voting")

# Fetch a page once; cache the HTML; sleep only on live requests.
bbr_get <- function(url, cache_name) {
  f <- file.path("data/raw/bbr", cache_name)
  if (!file.exists(f)) {
    cat("  fetching", url, "\n")
    Sys.sleep(BBR_SLEEP_SEC)
    resp <- tryCatch(read_html(url), error = function(e) NULL)
    if (is.null(resp)) stop("Could not fetch ", url, ". If this repeats you are rate-limited; wait and rerun.", call. = FALSE)
    writeLines(as.character(resp), f)
  }
  read_html(f)
}

# Sports-Reference hides some tables inside HTML comments; parse both.
bbr_tables <- function(page) {
  visible <- page %>% html_elements("table")
  hidden  <- page %>% html_elements(xpath = "//comment()") %>% html_text() %>%
    keep(~ str_detect(.x, "<table")) %>% map(~ read_html(.x) %>% html_elements("table")) %>% flatten()
  tabs <- c(visible, hidden)
  ids  <- map_chr(tabs, ~ coalesce(html_attr(.x, "id"), ""))
  set_names(tabs, ids)
}

# --- 3a. All-NBA teams: one page, all seasons
all_league_page <- bbr_get("https://www.basketball-reference.com/awards/all_league.html", "all_league.html")
all_league_tab  <- bbr_tables(all_league_page)[["awards_all_league"]]
check(!is.null(all_league_tab), "All-NBA table found (id 'awards_all_league')")

all_nba <- all_league_tab %>%
  html_table() %>%
  clean_names() %>%
  filter(lg == "NBA") %>%
  mutate(season = as.integer(str_sub(season, 1, 4)) + 1L) %>%     # "2023-24" -> 2024
  select(season, team = tm, starts_with("x")) %>%
  pivot_longer(starts_with("x"), values_to = "player_raw") %>%
  filter(player_raw != "") %>%
  mutate(player = str_remove(player_raw, "\\s+[A-Z]{1,2}$")) %>%   # strip trailing position letter(s)
  transmute(season, honor = paste0("all_nba_", team), player, name_key = norm_name(player)) %>%
  filter(season %in% (min(SEASONS) - 3):max(SEASONS))

check(nrow(all_nba) > 0, "All-NBA rows parsed")
check(all(all_nba %>% count(season) %>% pull(n) == 15), "15 All-NBA players per season")

# --- 3b. All-Star rosters: one page per season (skip 1999 lockout; 2021 had a game)
# all_star <- map_dfr((min(SEASONS) - 3):max(SEASONS), function(s) {
#   pg <- bbr_get(sprintf("https://www.basketball-reference.com/allstar/NBA_%d.html", s), sprintf("allstar_%d.html", s))
#   players <- pg %>% html_elements("table a[href*='/players/']") %>% html_text() %>% unique()
#   tibble(season = s, honor = "all_star", player = players)
# }) %>% mutate(name_key = norm_name(player))


all_star <- map_dfr((min(SEASONS) - 3):max(SEASONS), function(s) {
  pg   <- bbr_get(sprintf("https://www.basketball-reference.com/allstar/NBA_%d.html", s), sprintf("allstar_%d.html", s))
  tabs <- bbr_tables(pg)                                   # visible + commented tables
  players <- map(tabs, ~ html_elements(.x, "a[href*='/players/']") %>% html_text()) %>%
    unlist() %>% unique()
  tibble(season = s, honor = "all_star", player = players)
}) %>% mutate(name_key = norm_name(player))

all_star_manual <- read_csv("assets/all_star_manual.csv", show_col_types = FALSE) %>%
  transmute(season = as.integer(season), honor = "all_star", player, name_key = norm_name(player))
all_star <- all_star %>% filter(!season %in% all_star_manual$season) %>% bind_rows(all_star_manual)

as_counts <- all_star %>% count(season)
cat("\n  All-Star names parsed per season (expect 24-30):\n"); print(as_counts, n = Inf)
check(all(as_counts$n >= 20 & as_counts$n <= 34), "All-Star roster counts in a sane range")

# --- 3c. MVP and DPOY voting (contention proxy): one page per season
award_votes <- map_dfr((min(SEASONS) - 1):max(SEASONS), function(s) {
  pg   <- bbr_get(sprintf("https://www.basketball-reference.com/awards/awards_%d.html", s), sprintf("awards_%d.html", s))
  tabs <- bbr_tables(pg)
  map_dfr(c("mvp", "dpoy"), function(id) {
    if (is.null(tabs[[id]])) return(tibble())
    tabs[[id]] %>% html_table() %>% row_to_names(1) %>% clean_names() %>%
      transmute(season = s, honor = paste0(id, "_votes"), player, pts_won = suppressWarnings(as.numeric(pts_won)))
  })
}) %>% filter(!is.na(pts_won), pts_won > 0) %>% mutate(name_key = norm_name(player))

check(nrow(award_votes) > 0, "award voting rows parsed")

honors <- bind_rows(all_nba, all_star, award_votes %>% select(-pts_won)) %>% distinct(season, honor, name_key, player)
write_rds(honors, "data/intermediate/bbr_honors.rds")


# -----------------------------------------------------------------------------
# 4. NAME MATCHING AND THE LAGGED STAR FLAG
# -----------------------------------------------------------------------------
stage("STAGE 4: match BBR names to ESPN athlete_ids; build star flags")

# ESPN name keys, one row per athlete (most recent display name)
espn_names <- player_box %>%
  group_by(athlete_id) %>% summarise(athlete_name = last(athlete_name), .groups = "drop") %>%
  mutate(name_key = norm_name(athlete_name))

# Optional manual overrides: assets/name_overrides.csv with columns bbr_name, athlete_id
override_path <- "assets/name_overrides.csv"
if (!file.exists(override_path)) write_csv(tibble(bbr_name = character(), athlete_id = character()), override_path)
overrides <- read_csv(override_path, show_col_types = FALSE, col_types = cols(.default = "c")) %>%
  mutate(name_key = norm_name(bbr_name))

honors_matched <- honors %>%
  left_join(espn_names %>% select(name_key, athlete_id), by = "name_key") %>%
  left_join(overrides %>% select(name_key, athlete_id_override = athlete_id), by = "name_key") %>%
  mutate(athlete_id = coalesce(athlete_id_override, athlete_id)) %>%
  select(-athlete_id_override)

unmatched <- honors_matched %>% filter(is.na(athlete_id)) %>% distinct(player, name_key) %>% arrange(player)
cat("\n  Unmatched BBR names (add to assets/name_overrides.csv, then rerun):\n"); print(unmatched, n = Inf)
check(nrow(unmatched) / n_distinct(honors_matched$name_key) < 0.05,
      "fewer than 5% of honored names unmatched (fix the rest via overrides)")

dupes <- espn_names %>% count(name_key) %>% filter(n > 1)
if (nrow(dupes)) { cat("  NOTE: ESPN name keys shared by >1 athlete_id (check these):\n"); print(dupes) }

honors_matched <- honors_matched %>% filter(!is.na(athlete_id))

# Lagged flags for each analysis season s:
#   star_ppp   : All-Star or All-NBA in any of seasons s-3..s-1   (PPP definition)
#   contender  : All-NBA, or any MVP/DPOY votes, in season s-1   (incentive plausibly binds)
star_flags <- map_dfr(SEASONS, function(s) {
  prior3 <- honors_matched %>% filter(season %in% (s - 3):(s - 1), honor %in% c("all_star") | str_starts(honor, "all_nba"))
  prior1 <- honors_matched %>% filter(season == s - 1, str_starts(honor, "all_nba") | str_ends(honor, "_votes"))
  tibble(season = s, athlete_id = unique(c(prior3$athlete_id, prior1$athlete_id))) %>%
    mutate(star_ppp  = athlete_id %in% prior3$athlete_id,
           contender = athlete_id %in% prior1$athlete_id)
})

star_counts <- star_flags %>% group_by(season) %>% summarise(stars = sum(star_ppp), contenders = sum(contender), .groups = "drop")
cat("\n  Star and contender counts by season (expect ~40-50 and ~30-40):\n"); print(star_counts, n = Inf)
check(all(star_counts$stars >= 30 & star_counts$stars <= 65), "star counts in expected range")

write_rds(star_flags, "data/intermediate/star_flags.rds")


# -----------------------------------------------------------------------------
# 5. PLAYER-SEASON TABLE WITH QUALIFYING GAMES
# -----------------------------------------------------------------------------
stage("STAGE 5: player-season table")

# Qualifying games under the rule: games with >= 20 min, plus up to two games with 15-19 min.
player_season <- player_box %>%
  group_by(season, athlete_id) %>%
  summarise(
    athlete_name  = last(athlete_name),
    teams         = n_distinct(team_id),
    games_rostered = n(),
    games_played  = sum(played),
    games_missed  = games_rostered - games_played,
    dnp_injury    = sum(did_not_play & str_detect(coalesce(reason, ""), regex("injur|ill", ignore_case = TRUE))),
    dnp_rest      = sum(did_not_play & str_detect(coalesce(reason, ""), regex("rest", ignore_case = TRUE))),
    dnp_coach     = sum(did_not_play & str_detect(coalesce(reason, ""), regex("coach", ignore_case = TRUE))),
    total_minutes = sum(minutes),
    mpg           = if_else(games_played > 0, total_minutes / games_played, 0),
    g_20plus      = sum(played & minutes >= RULE_MIN),
    g_15to19      = sum(played & minutes >= RULE_MIN_LOW & minutes < RULE_MIN),
    qualifying_games = g_20plus + pmin(g_15to19, RULE_LOW_ALLOW),
    .groups = "drop"
  ) %>%
  left_join(star_flags, by = c("season", "athlete_id")) %>%
  mutate(across(c(star_ppp, contender), ~ replace_na(.x, FALSE)),
         covid = season %in% COVID_SEASONS, post_rule = season %in% POST_SEASONS,
         high_minute_nonstar = !star_ppp & mpg >= 28 & games_played >= 40)

# --- Checks
check(!any(duplicated(player_season[c("season", "athlete_id")])), "player-season unique")
check(all(player_season$qualifying_games <= player_season$games_played), "qualifying games <= games played")
cat("\n  Star player-seasons by season, with mean games played and mean qualifying games:\n")
player_season %>% filter(star_ppp) %>% group_by(season) %>%
  summarise(n = n(), gp = round(mean(games_played), 1), qg = round(mean(qualifying_games), 1),
            share_ge65 = round(mean(qualifying_games >= RULE_GAMES), 2), .groups = "drop") %>% print(n = Inf)

write_rds(player_season, "data/derived/player_season.rds")
write_csv(player_season, "data/derived/player_season.csv")


# -----------------------------------------------------------------------------
# 6. GAMES-PLAYED DISTRIBUTION FOR STARS, PRE VS POST
# -----------------------------------------------------------------------------
stage("STAGE 6: bunching go/no-go figure")

bunch_df <- player_season %>%
  filter(star_ppp, !covid) %>%
  mutate(period = if_else(post_rule, "Post-rule (2023-24 to 2025-26)", "Pre-rule (2013-14 to 2022-23, ex-COVID)"))

p <- ggplot(bunch_df, aes(x = qualifying_games)) +
  geom_histogram(binwidth = 1, boundary = 0.5, fill = "grey40") +
  geom_vline(xintercept = RULE_GAMES - 0.5, linetype = "dashed", colour = "firebrick") +
  facet_wrap(~ period, ncol = 1, scales = "free_y") +
  scale_x_continuous(breaks = seq(0, 82, 10), limits = c(0, 83)) +
  labs(x = "Qualifying games (>= 20 min, plus up to two 15-19 min games)", y = "Player-seasons",
       title = "Games played by stars (All-Star or All-NBA in prior three seasons)",
       subtitle = "Dashed line: 65-game award-eligibility threshold") +
  theme_minimal(base_size = 12)

ggsave("results/figures/bunching_go_no_go.png", p, width = 8, height = 7, dpi = 200)

# Mass just below vs just above the threshold
bunch_tab <- bunch_df %>%
  mutate(bin = case_when(qualifying_games %in% 58:64 ~ "58-64 (below)",
                         qualifying_games %in% 65:68 ~ "65-68 (just above)",
                         qualifying_games >= 69      ~ "69+",
                         TRUE                        ~ "<58")) %>%
  count(period, bin) %>% group_by(period) %>% mutate(share = round(n / sum(n), 3)) %>% ungroup() %>%
  pivot_wider(names_from = period, values_from = c(n, share))
cat("\n  Mass around the threshold, stars, pre vs post:\n"); print(bunch_tab, width = Inf)
write_csv(bunch_tab, "results/tables/bunching_go_no_go.csv")



# At-risk analysis: stars near the threshold with ~20 games left. Did they get there?
game_idx <- player_box %>%
  distinct(season, team_id, game_id, game_date) %>%
  arrange(season, team_id, game_date) %>%
  group_by(season, team_id) %>% mutate(team_game_no = row_number(), team_games = n()) %>% ungroup()

at_risk <- player_box %>%
  inner_join(game_idx %>% select(game_id, team_id, team_game_no, team_games), by = c("game_id", "team_id")) %>%
  filter(team_game_no <= 62) %>%
  group_by(season, athlete_id) %>%
  summarise(q_thru_62 = sum(played & minutes >= RULE_MIN), .groups = "drop") %>%
  inner_join(player_season %>% select(season, athlete_id, qualifying_games, star_ppp, contender, covid, post_rule),
             by = c("season", "athlete_id")) %>%
  filter(star_ppp, !covid) %>%
  mutate(slack_at_62 = q_thru_62 + 20 - RULE_GAMES,          # games he can still miss
         reached = qualifying_games >= RULE_GAMES)

at_risk %>%
  filter(slack_at_62 >= 0, slack_at_62 <= 8) %>%
  group_by(post_rule, contender, slack_bin = cut(slack_at_62, c(-1, 2, 5, 8))) %>%
  summarise(n = n(), reached = round(mean(reached), 2), .groups = "drop") %>%
  pivot_wider(names_from = post_rule, values_from = c(n, reached)) %>% print()



# -----------------------------------------------------------------------------
# 7. EXPLORATORY ANALYSIS
# -----------------------------------------------------------------------------

library(fixest)
did_df <- player_season %>%
  filter(!covid, star_ppp | high_minute_nonstar, games_rostered >= 40) %>%
  mutate(rel = factor(season, levels = setdiff(SEASONS, COVID_SEASONS)))

feols(games_played ~ i(rel, star_ppp, ref = "2023") | athlete_id + season, did_df, cluster = ~athlete_id) %>%
  coeftable() %>% round(2)
feols(qualifying_games ~ i(rel, star_ppp, ref = "2023") | athlete_id + season, did_df, cluster = ~athlete_id) %>%
  coeftable() %>% round(2)



h3 <- player_box %>%
  inner_join(game_idx %>% select(game_id, team_id, team_game_no), by = c("game_id", "team_id")) %>%
  inner_join(player_season %>% select(season, athlete_id, star_ppp, contender), by = c("season", "athlete_id")) %>%
  filter(star_ppp, !covid) %>%
  arrange(season, athlete_id, team_game_no) %>%
  group_by(season, athlete_id) %>%
  mutate(nonqual   = !(played & minutes >= RULE_MIN),
         missed_ct = cumsum(nonqual),
         crossed   = missed_ct > (82 - RULE_GAMES),                  # 65 now unreachable
         cross_game = if (any(crossed)) min(team_game_no[crossed]) else NA_integer_,
         rel_game  = team_game_no - cross_game) %>%
  ungroup() %>%
  filter(!is.na(cross_game), cross_game <= 70, rel_game >= -10, rel_game <= 12)   # crossings with games left to observe

feols(played ~ i(rel_game, post_rule, ref = -1) | athlete_id^season + rel_game, h3, cluster = ~athlete_id) %>%
  coeftable() %>% round(3)



# H8 redesign: among HEALTHY stars (played the previous game), does the rest rate depend on
# whether 65 is still reachable, and does that dependence appear only post-rule?
h8 <- player_box %>%
  inner_join(game_idx %>% select(game_id, team_id, team_game_no, team_games), by = c("game_id", "team_id")) %>%
  inner_join(player_season %>% select(season, athlete_id, star_ppp, contender), by = c("season", "athlete_id")) %>%
  filter(star_ppp, !covid) %>%
  arrange(season, athlete_id, team_game_no) %>%
  group_by(season, athlete_id) %>%
  mutate(qual        = played & minutes >= RULE_MIN,
         q_sofar     = lag(cumsum(qual), default = 0),
         remaining   = team_games - team_game_no + 1,
         reachable   = q_sofar + remaining >= RULE_GAMES,
         secured     = q_sofar >= RULE_GAMES,
         healthy     = lag(played, default = FALSE),                 # played the previous game
         late_season = team_game_no > 55) %>%
  ungroup() %>%
  filter(healthy, late_season) %>%
  mutate(state = case_when(secured ~ "secured", reachable ~ "reachable", TRUE ~ "unreachable"),
         sat = !played)

# Cell sizes first
h8 %>% count(post_rule, state) %>% pivot_wider(names_from = post_rule, values_from = n) %>% print()

# Rest rate of healthy stars by eligibility state, pre vs post
h8 %>% group_by(post_rule, state) %>% summarise(n = n(), sat = round(mean(sat), 3), .groups = "drop") %>%
  pivot_wider(names_from = post_rule, values_from = c(n, sat)) %>% print()

feols(sat ~ i(state, post_rule, ref = "reachable") | athlete_id^season + team_game_no, h8, cluster = ~athlete_id) %>%
  coeftable() %>% round(3)



# Season x state rest rates (healthy, late-season stars)
h8 %>%
  group_by(season, state) %>%
  summarise(n = n(), sat = round(mean(sat), 3), .groups = "drop") %>%
  pivot_wider(names_from = state, values_from = c(n, sat)) %>%
  select(season, starts_with("sat_"), starts_with("n_")) %>%
  print(n = Inf, width = Inf)

# Event-study version: gap between non-reachable states and reachable, by season, ref 2023
h8 %>%
  mutate(no_incentive = state != "reachable", rel = factor(season, levels = setdiff(SEASONS, COVID_SEASONS))) %>%
  feols(sat ~ i(rel, no_incentive, ref = "2023") | athlete_id^season + team_game_no, data = ., cluster = ~athlete_id) %>%
  coeftable() %>% round(3)



# Attach the national-TV flag
h8_tv <- h8 %>%
  inner_join(schedule %>% select(game_id, national_tv, broadcast), by = "game_id")

# Sanity: share of games flagged national TV by season (expect ~15-25%; check the broadcast strings)
h8_tv %>% distinct(season, game_id, national_tv) %>% group_by(season) %>%
  summarise(share_natl = round(mean(national_tv), 2), .groups = "drop") %>% print(n = Inf)
h8_tv %>% distinct(game_id, broadcast) %>% count(broadcast, sort = TRUE) %>% head(15) %>% print()

# Rest rates by TV status, pre vs post
h8_tv %>%
  group_by(post_rule, national_tv) %>%
  summarise(n = n(), sat = round(mean(sat), 3), .groups = "drop") %>%
  pivot_wider(names_from = post_rule, values_from = c(n, sat)) %>% print()

# Triple difference: does the post-rule rest decline differ on national TV?
feols(sat ~ post_rule:national_tv + national_tv | athlete_id^season + team_game_no, h8_tv, cluster = ~athlete_id) %>%
  coeftable() %>% round(3)

# Same, split by eligibility state (the PPP effect should show on TV in every state; the notch would not)
feols(sat ~ post_rule:national_tv:state + national_tv:state | athlete_id^season + team_game_no, h8_tv, cluster = ~athlete_id) %>%
  coeftable() %>% round(3)




h8_all <- player_box %>%
  inner_join(game_idx %>% select(game_id, team_id, team_game_no, team_games), by = c("game_id", "team_id")) %>%
  inner_join(player_season %>% select(season, athlete_id, star_ppp, high_minute_nonstar), by = c("season", "athlete_id")) %>%
  filter(star_ppp | high_minute_nonstar, !covid) %>%
  arrange(season, athlete_id, team_game_no) %>%
  group_by(season, athlete_id) %>%
  mutate(healthy = lag(played, default = FALSE), late_season = team_game_no > 55) %>%
  ungroup() %>%
  filter(healthy, late_season) %>%
  mutate(sat = !played, rel = factor(season, levels = setdiff(SEASONS, COVID_SEASONS)))

h8_all %>% group_by(season, star_ppp) %>% summarise(sat = round(mean(sat), 3), .groups = "drop") %>%
  pivot_wider(names_from = star_ppp, values_from = sat, names_prefix = "star_") %>% print(n = Inf)

feols(sat ~ i(rel, star_ppp, ref = "2023") | athlete_id + season + team_game_no, h8_all, cluster = ~athlete_id) %>%
  coeftable() %>% round(3)

# Same thing with 2017 as the reference, to test the 2017-18 resting policy as a break
feols(sat ~ i(rel, star_ppp, ref = "2017") | athlete_id + season + team_game_no, h8_all, cluster = ~athlete_id) %>%
  coeftable() %>% round(3)



# H4: minute distribution for stars who play, late season, by whether 65 is still reachable but not secured
h4 <- player_box %>%
  inner_join(game_idx %>% select(game_id, team_id, team_game_no, team_games), by = c("game_id", "team_id")) %>%
  inner_join(player_season %>% select(season, athlete_id, star_ppp), by = c("season", "athlete_id")) %>%
  filter(star_ppp, !covid, played) %>%
  arrange(season, athlete_id, team_game_no) %>%
  group_by(season, athlete_id) %>%
  mutate(q_sofar = lag(cumsum(played & minutes >= RULE_MIN), default = 0),
         remaining = team_games - team_game_no + 1,
         slack = q_sofar + remaining - RULE_GAMES,
         tight = slack >= 0 & slack <= 3 & q_sofar < RULE_GAMES & team_game_no > 55) %>%
  ungroup()

h4 %>% filter(team_game_no > 55) %>%
  mutate(min_bin = cut(minutes, c(0, 14, 19, 22, 30, 60), labels = c("<15", "15-19", "20-22", "23-30", "31+"))) %>%
  count(post_rule, tight, min_bin) %>% group_by(post_rule, tight) %>% mutate(share = round(n / sum(n), 3)) %>% ungroup() %>%
  select(-n) %>% pivot_wider(names_from = c(post_rule, tight), values_from = share) %>% print()


cat("\n  figure saved to results/figures/bunching_go_no_go.png\n")
cat("\nDone.\n")