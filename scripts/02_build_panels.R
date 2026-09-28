# =============================================================================
# 02_build_panels.R
#
# NBA 65-game rule: build the analysis panels
#
# Inputs (built by 01_setup_and_pull.R; not modified here)
#   data/intermediate/player_box.rds   player-game rows, regular season, 2014-2026
#   data/intermediate/schedule.rds     game dates and broadcast strings
#   data/derived/player_season.rds     player-season table with star flags
#   data/raw/player_box_raw.rds        raw hoopR pull (read only, for pts/reb/ast)
#
# Outputs (data/derived unless noted)
#   game_idx.rds             team_game_no and team_games for every team-game; exhibition
#                            games removed; the NBA Cup final kept and flagged (cup_final)
#   excluded_games.rds       the team-games removed from game_idx and why
#   player_season_clean.rds  player_season.rds with games_played, qualifying_games
#                            etc. recomputed on regular-season games only
#   player_game_panel.rds    player-game panel on the FULL team schedule, stars and
#                            high-minute non-stars, with has_row / absence_type, q_sofar,
#                            remaining, slack, state, healthy, late_season
#   dnp_row_coverage.rds     share of absences that appear as ESPN DNP rows, by season
#   contention_proxy.rds     current-season contention proxy (top-30 pts+reb+ast per
#                            game through team game 62, 40+ games played)
#   at_risk.rds              star-seasons with slack at team game 62
#   results/tables/at_risk_*.csv   the at-risk tables (legacy replication + improved)
#
# Stages end with check() assertions that stop the script if something is off.
# =============================================================================


# -----------------------------------------------------------------------------
# 0. SETUP
# -----------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
})

PROJECT_ROOT <- "/Users/maddockl/nba-65-game-rule"
setwd(PROJECT_ROOT)

SEASONS        <- 2014:2026
COVID_SEASONS  <- c(2020, 2021)
POST_SEASONS   <- 2024:2026
RULE_GAMES     <- 65
RULE_MIN       <- 20
RULE_MIN_LOW   <- 15
RULE_LOW_ALLOW <- 2
LATE_GAME      <- 55     # late_season = team_game_no > 55
AT_RISK_GAME   <- 62     # slack measured at team game 62
EXHIBITION_MAX <- 10     # a "team" with <= 10 games in a season is an All-Star / Rising Stars side

# The NBA Cup (in-season tournament) final is carried by ESPN as a regular-season game. It does
# NOT count toward regular-season statistics (Basketball-Reference omits it) but it DOES count
# toward the 65-game award-eligibility threshold (confirmed 2026-09-16: Wembanyama reached 65
# in 2026 by the league's count with 64 regular-season games plus the Cup final). The game is
# kept in the index with a cup_final flag; qualifying games include it, games played do not.
CUP_FINAL_DATES <- as_date(c("2023-12-09", "2024-12-17", "2025-12-16"))

stage <- function(txt) cat("\n", strrep("=", 78), "\n", txt, "\n", strrep("=", 78), "\n", sep = "")
check <- function(cond, msg) {
  if (!isTRUE(cond)) stop("CHECK FAILED: ", msg, call. = FALSE)
  cat("  ok:", msg, "\n")
}
pr <- function(x, ...) print(x, n = Inf, width = Inf, ...)

player_box    <- read_rds("data/intermediate/player_box.rds")
schedule      <- read_rds("data/intermediate/schedule.rds")
player_season <- read_rds("data/derived/player_season.rds")

check(all(c("game_id", "season", "game_date", "athlete_id", "team_id", "minutes", "played",
            "did_not_play", "reason", "covid", "post_rule") %in% names(player_box)), "player_box has required columns")
check(all(c("season", "athlete_id", "star_ppp", "contender", "high_minute_nonstar",
            "qualifying_games", "games_played") %in% names(player_season)), "player_season has required columns")
check(!any(duplicated(player_box[c("game_id", "athlete_id")])), "player_box unique on game_id x athlete_id")
cat("  player_box rows:", nrow(player_box), " player_season rows:", nrow(player_season), "\n")


# -----------------------------------------------------------------------------
# 1. GAME INDEX: team_game_no and team_games, regular-season games only
# -----------------------------------------------------------------------------
stage("STAGE 1: game index")

# 1a. Every team-game in the box scores, numbered naively (this is what the
#     exploratory code used; kept for the replication block in stage 5).
game_idx_legacy <- player_box %>%
  distinct(season, team_id, game_id, game_date) %>%
  arrange(season, team_id, game_date, game_id) %>%
  group_by(season, team_id) %>%
  mutate(team_game_no = row_number(), team_games = n()) %>%
  ungroup()

# 1b. Flag what is not a regular-season game.
#     - exhibition: All-Star game, Rising Stars, etc. Appear under their own
#       team_ids (EAST/WEST, LEB/GIA, USA/WORLD, ...) with 1-3 games a season.
#     - cup_final: the NBA Cup final, seasons 2024+, gives two teams an 83rd game.
team_counts <- game_idx_legacy %>% distinct(season, team_id, team_games)
exhibition_teams <- team_counts %>% filter(team_games <= EXHIBITION_MAX) %>% select(season, team_id)

cup_final_games <- game_idx_legacy %>%
  filter(season >= 2024, game_date %in% CUP_FINAL_DATES) %>%
  group_by(season, game_id) %>%
  filter(n() == 2, all(team_games == 83)) %>%          # both teams carry an 83rd game
  ungroup() %>%
  distinct(season, game_id)

excluded_games <- game_idx_legacy %>% semi_join(exhibition_teams, by = c("season", "team_id")) %>% mutate(why = "exhibition") %>%
  select(season, team_id, game_id, game_date, why)

cat("\n  Team-games excluded from the game index, by season and reason:\n")
pr(excluded_games %>% count(season, why) %>% pivot_wider(names_from = why, values_from = n, values_fill = 0))

check(nrow(cup_final_games) == 3, "exactly one NBA Cup final per season 2024-2026")
check(all(exhibition_teams$team_id %in% c(player_box %>% filter(team_abbr %in% c("EAST", "WEST", "LEB", "STE", "GIA", "DUR",
                                                                                   "USA", "WORLD", "CHK", "SHQ", "KEN", "CAN",
                                                                                   "STARS", "STRIPES")) %>% pull(team_id))),
      "exhibition team_ids are All-Star / Rising Stars sides")

# 1c. Rebuild the index without exhibitions; flag the Cup final (kept, counts for the rule only).
game_idx <- game_idx_legacy %>%
  select(-team_game_no, -team_games) %>%
  anti_join(excluded_games, by = c("season", "team_id", "game_id")) %>%
  mutate(cup_final = game_id %in% cup_final_games$game_id) %>%
  arrange(season, team_id, game_date, game_id) %>%
  group_by(season, team_id) %>%
  mutate(team_game_no = row_number(), team_games = n()) %>%
  ungroup()
cat("  Cup final team-games kept in the index (count for the 65-game rule, not for statistics):", sum(game_idx$cup_final), "\n")

teams_per_game <- game_idx %>% count(season, game_id)
check(all(teams_per_game$n == 2), "every game in the index has exactly two teams")
check(!any(duplicated(game_idx[c("game_id", "team_id")])), "game index unique on game_id x team_id")

tg <- game_idx %>% group_by(season, team_id) %>% summarise(team_games = n(), regular_games = sum(!cup_final), .groups = "drop")
cat("\n  Regular-season games per team, by season (82 outside COVID; four seasons have one game ESPN never posted):\n")
pr(tg %>% count(season, regular_games) %>% pivot_wider(names_from = regular_games, values_from = n, values_fill = 0))
check(all(tg$regular_games[!tg$season %in% COVID_SEASONS] %in% 81:82), "non-COVID teams have 81 or 82 regular-season games")
check(all(tg$regular_games[!tg$season %in% COVID_SEASONS] == 82 | tg$season[!tg$season %in% COVID_SEASONS] %in% c(2014, 2017, 2018, 2019)),
      "81-game teams appear only in 2014, 2017, 2018, 2019 (one unposted game each)")
check(sum(tg$team_games - tg$regular_games) == 6, "six Cup-finalist team-seasons carry an 83rd game")
check(n_distinct(tg$team_id[!tg$season %in% COVID_SEASONS]) == 30, "30 NBA teams in the index")

write_rds(game_idx, "data/derived/game_idx.rds")
write_rds(excluded_games, "data/derived/excluded_games.rds")
cat("  saved data/derived/game_idx.rds (", nrow(game_idx), " team-games) and excluded_games.rds\n", sep = "")


# -----------------------------------------------------------------------------
# 2. PLAYER-SEASON COUNTS ON REGULAR-SEASON GAMES ONLY
#    player_season.rds (from script 01) counts All-Star game and NBA Cup final
#    rows as games. Recompute the game counts on the clean index; keep the
#    script-01 flags (star_ppp, contender, high_minute_nonstar) unchanged.
# -----------------------------------------------------------------------------
stage("STAGE 2: player-season counts, regular-season games only")

box_reg <- player_box %>%
  inner_join(game_idx %>% select(game_id, team_id, team_game_no, team_games, cup_final), by = c("game_id", "team_id"))
check(nrow(box_reg) == nrow(player_box) - nrow(semi_join(player_box, excluded_games, by = c("game_id", "team_id"))),
      "regular-season box rows = all rows minus excluded team-games")

# games_played and mpg are regular-season statistics (Cup final excluded, as on Basketball-Reference);
# qualifying_games follows the rule (Cup final included). games_played_rule counts every appearance.
ps_clean_counts <- box_reg %>%
  group_by(season, athlete_id) %>%
  summarise(
    games_rostered   = sum(!cup_final),
    games_played     = sum(played & !cup_final),
    games_played_rule = sum(played),
    games_missed     = games_rostered - games_played,
    total_minutes    = sum(minutes[!cup_final]),
    mpg              = if_else(games_played > 0, total_minutes / games_played, 0),
    g_20plus         = sum(played & minutes >= RULE_MIN),
    g_15to19         = sum(played & minutes >= RULE_MIN_LOW & minutes < RULE_MIN),
    qualifying_games = g_20plus + pmin(g_15to19, RULE_LOW_ALLOW),
    qualifying_games_regular = sum(played & !cup_final & minutes >= RULE_MIN) + pmin(sum(played & !cup_final & minutes >= RULE_MIN_LOW & minutes < RULE_MIN), RULE_LOW_ALLOW),
    .groups = "drop"
  )

player_season_clean <- player_season %>%
  select(season, athlete_id, athlete_name, teams, dnp_injury, dnp_rest, dnp_coach,
         star_ppp, contender, covid, post_rule, high_minute_nonstar,
         games_rostered_orig = games_rostered, games_played_orig = games_played,
         qualifying_games_orig = qualifying_games, mpg_orig = mpg) %>%
  left_join(ps_clean_counts, by = c("season", "athlete_id")) %>%
  # players whose only rows were exhibition games drop out of the clean counts
  filter(!is.na(games_rostered)) %>%
  mutate(high_minute_nonstar_clean = !star_ppp & mpg >= 28 & games_played >= 40)

# Lagged control groups: status in season s-1, so that membership is fixed before the outcome
# is realised (the contemporaneous high_minute_nonstar flag conditions on games_played >= 40 in
# season s, which truncates the control group's outcome distribution).
lag_status <- player_season_clean %>%
  transmute(season = season + 1L, athlete_id,
            hm_prev  = mpg >= 28 & games_played >= 40,
            rot_prev = mpg >= 20 & games_played >= 40)
player_season_clean <- player_season_clean %>%
  left_join(lag_status, by = c("season", "athlete_id")) %>%
  mutate(across(c(hm_prev, rot_prev), ~ replace_na(.x, FALSE)),
         hm_lag  = !star_ppp & hm_prev,        # primary control: high-minute non-star in s-1
         rot_lag = !star_ppp & rot_prev)       # robustness control: rotation player in s-1
cat("\n  Control-group counts by season (contemporaneous vs lagged definitions):\n")
pr(player_season_clean %>% filter(!covid) %>% group_by(season) %>%
     summarise(stars = sum(star_ppp), n_hm_current = sum(high_minute_nonstar), n_hm_lag = sum(hm_lag), n_rot_lag = sum(rot_lag),
               gp_hm_current = round(mean(games_played[high_minute_nonstar]), 1), gp_hm_lag = round(mean(games_played[hm_lag]), 1), .groups = "drop"))
check(all(player_season_clean$hm_lag[player_season_clean$season == 2014] == FALSE), "no lagged control in 2014 (no 2013 data)")

check(!any(duplicated(player_season_clean[c("season", "athlete_id")])), "player_season_clean unique on season x athlete_id")
check(all(player_season_clean$qualifying_games <= player_season_clean$games_played_rule), "qualifying games <= games played under the rule")
check(all(player_season_clean$games_played <= player_season_clean$games_played_orig), "clean games played never exceed script-01 counts")
cup_players <- player_season_clean %>% filter(qualifying_games != qualifying_games_regular)
cat("  player-seasons whose rule count includes a Cup-final qualifying game:", nrow(cup_players), "; stars among them:", sum(cup_players$star_ppp), "\n")
pr(cup_players %>% filter(star_ppp) %>% select(season, athlete_name, games_played, games_played_rule, qualifying_games_regular, qualifying_games))
check(sum(player_season_clean$star_ppp) == sum(player_season$star_ppp), "no star player-seasons lost")

cat("\n  Effect of removing exhibition rows (and, for games played, the Cup final) on STAR player-seasons:\n")
diff_tab <- player_season_clean %>%
  filter(star_ppp) %>%
  group_by(season) %>%
  summarise(n = n(),
            n_gp_changed = sum(games_played != games_played_orig),
            n_qg_changed = sum(qualifying_games != qualifying_games_orig),
            gp_orig = round(mean(games_played_orig), 1), gp_clean = round(mean(games_played), 1),
            qg_orig = round(mean(qualifying_games_orig), 1), qg_clean = round(mean(qualifying_games), 1),
            ge65_orig = round(mean(qualifying_games_orig >= RULE_GAMES), 2),
            ge65_clean = round(mean(qualifying_games >= RULE_GAMES), 2),
            crossed_65 = sum(qualifying_games_orig >= RULE_GAMES & qualifying_games < RULE_GAMES),
            .groups = "drop")
pr(diff_tab)
cat("\n  Star-seasons that reach 65 in the raw count but not under the rule (All-Star game rows):\n")
pr(player_season_clean %>% filter(star_ppp, qualifying_games_orig >= RULE_GAMES, qualifying_games < RULE_GAMES) %>%
     select(season, athlete_name, qualifying_games_orig, qualifying_games, games_played_orig, games_played))
cat("\n  high_minute_nonstar flag changes after cleaning (expect ~0):",
    sum(player_season_clean$high_minute_nonstar != player_season_clean$high_minute_nonstar_clean), "\n")

write_rds(player_season_clean, "data/derived/player_season_clean.rds")
write_csv(player_season_clean, "data/derived/player_season_clean.csv")
write_csv(diff_tab, "results/tables/star_counts_orig_vs_clean.csv")
cat("  saved data/derived/player_season_clean.rds\n")


# -----------------------------------------------------------------------------
# 3. PLAYER-GAME PANEL: stars and high-minute non-stars
# -----------------------------------------------------------------------------
stage("STAGE 3: player-game panel")

# ESPN prints a box-score row only for players it lists. Most absences have no
# row at all (see the coverage table below), so the panel is built on the full
# schedule of each player's team stint(s): every team game between the first
# and last game of a stint, with the first stint extended back to team game 1
# and the last stint forward to the end of the season. has_row marks games with
# an ESPN row; absence_type separates played / DNP row / no row.

flags <- player_season_clean %>%
  select(season, athlete_id, athlete_name, star_ppp, contender, high_minute_nonstar, hm_lag,
         qualifying_games_season = qualifying_games, games_played_season = games_played)
flag_rows <- box_reg %>% semi_join(flags %>% filter(star_ppp | high_minute_nonstar | hm_lag), by = c("season", "athlete_id"))
team_abbr_lu <- player_box %>% group_by(team_id) %>% summarise(team_abbr = last(team_abbr), .groups = "drop")

stints <- flag_rows %>%
  group_by(season, athlete_id, team_id) %>%
  summarise(first_no = min(team_game_no), last_no = max(team_game_no), first_date = min(game_date),
            last_date = max(game_date), team_games = first(team_games), n_rows = n(), .groups = "drop") %>%
  arrange(season, athlete_id, first_date) %>%
  group_by(season, athlete_id) %>%
  mutate(stint = row_number(), n_stints = n(),
         start_no = if_else(stint == 1L, 1L, first_no),
         end_no   = if_else(stint == n_stints, team_games, last_no)) %>%
  ungroup()

sched_rows <- stints %>%
  mutate(team_game_no = map2(start_no, end_no, seq)) %>%
  select(season, athlete_id, team_id, stint, n_stints, team_game_no) %>%
  unnest(team_game_no) %>%
  inner_join(game_idx %>% select(season, team_id, game_id, game_date, team_game_no, team_games),
             by = c("season", "team_id", "team_game_no"))

panel <- sched_rows %>%
  left_join(flag_rows %>% select(game_id, athlete_id, minutes, played, did_not_play, reason, starter, active, cup_final),
            by = c("game_id", "athlete_id")) %>%
  left_join(game_idx %>% select(game_id, team_id, cup_final_idx = cup_final), by = c("game_id", "team_id")) %>%
  mutate(cup_final = coalesce(cup_final, cup_final_idx)) %>% select(-cup_final_idx) %>%
  mutate(has_row      = !is.na(played),
         played       = replace_na(played, FALSE),
         minutes      = replace_na(minutes, 0),
         did_not_play = if_else(has_row, did_not_play, TRUE),
         absence_type = case_when(played ~ "played", has_row ~ "dnp_row", TRUE ~ "no_row")) %>%
  # a handful of trade-day overlaps put two team games on one date: keep the game with a row
  arrange(season, athlete_id, game_date, desc(played), desc(has_row), game_id) %>%
  distinct(season, athlete_id, game_date, .keep_all = TRUE) %>%
  inner_join(flags, by = c("season", "athlete_id")) %>%
  mutate(covid = season %in% COVID_SEASONS, post_rule = season %in% POST_SEASONS) %>%
  left_join(team_abbr_lu, by = "team_id") %>%
  left_join(schedule %>% select(game_id, broadcast, national_tv), by = "game_id") %>%
  arrange(season, athlete_id, game_date, game_id) %>%
  group_by(season, athlete_id) %>%
  mutate(
    player_game_no = row_number(),
    first_row_date = min(game_date[has_row]), last_row_date = max(game_date[has_row]),
    in_row_span    = game_date >= first_row_date & game_date <= last_row_date,
    qual20         = played & minutes >= RULE_MIN,
    qual15         = played & minutes >= RULE_MIN_LOW & minutes < RULE_MIN,
    q_thru         = cumsum(qual20) + pmin(cumsum(qual15), RULE_LOW_ALLOW),
    q_thru_strict  = cumsum(qual20),
    q_sofar        = lag(q_thru, default = 0L),
    q_sofar_strict = lag(q_thru_strict, default = 0L),
    remaining      = team_games - team_game_no + 1L,
    slack          = q_sofar + remaining - RULE_GAMES,
    slack_strict   = q_sofar_strict + remaining - RULE_GAMES,
    state          = case_when(q_sofar >= RULE_GAMES ~ "secured", slack >= 0 ~ "reachable", TRUE ~ "unreachable"),
    state_strict   = case_when(q_sofar_strict >= RULE_GAMES ~ "secured", slack_strict >= 0 ~ "reachable", TRUE ~ "unreachable"),
    healthy        = lag(played, default = FALSE),                       # played the team's previous game
    played_prev3   = lag(played, 1, default = FALSE) + lag(played, 2, default = FALSE) + lag(played, 3, default = FALSE),
    late_season    = team_game_no > LATE_GAME,
    sat            = !played,
    tight          = slack >= 0 & slack <= 3 & q_sofar < RULE_GAMES,
    min_bin        = cut(minutes, c(-Inf, 14, 19, 22, 30, Inf), labels = c("<15", "15-19", "20-22", "23-30", "31+"))
  ) %>%
  ungroup() %>%
  # rows-only replication flag: the exploratory "healthy" was lag(played) over ESPN rows only
  group_by(season, athlete_id) %>%
  mutate(row_seq = if_else(has_row, cumsum(has_row), NA_integer_)) %>%
  ungroup() %>%
  left_join(
    (.) %>% filter(has_row) %>% arrange(season, athlete_id, row_seq) %>% group_by(season, athlete_id) %>%
      transmute(row_seq, healthy_rows = lag(played, default = FALSE)) %>% ungroup(),
    by = c("season", "athlete_id", "row_seq")) %>%
  mutate(state = factor(state, levels = c("reachable", "secured", "unreachable")),
         state_strict = factor(state_strict, levels = c("reachable", "secured", "unreachable")),
         group = case_when(star_ppp ~ "star", hm_lag ~ "high_minute_nonstar", TRUE ~ "current_def_only")) %>%
  select(season, covid, post_rule, athlete_id, athlete_name, team_id, team_abbr, stint, n_stints, game_id, game_date,
         team_game_no, team_games, player_game_no, remaining, in_row_span,
         group, star_ppp, contender, high_minute_nonstar, hm_lag,
         has_row, absence_type, cup_final, minutes, played, did_not_play, reason, starter, active, sat, min_bin,
         qual20, qual15, q_thru, q_sofar, slack, state, q_thru_strict, q_sofar_strict, slack_strict, state_strict,
         healthy, healthy_rows, played_prev3, late_season, tight,
         qualifying_games_season, games_played_season, broadcast, national_tv)

check(!any(duplicated(panel[c("season", "athlete_id", "game_date")])), "panel unique on season x athlete_id x game_date")
check(sum(panel$has_row) >= nrow(flag_rows) - 10, "all but a handful of ESPN rows carried into the panel")
one_team <- panel %>% filter(n_stints == 1, !covid) %>% count(season, athlete_id, team_games) %>% filter(n != team_games)
check(nrow(one_team) == 0, "single-team player-seasons cover every team game (non-COVID; 2020 has one duplicated date)")
check(all(panel$remaining >= 1), "remaining >= 1 everywhere")
check(all((panel$q_sofar >= RULE_GAMES) == (panel$state == "secured")), "secured <=> q_sofar >= 65")
check(all((panel$state == "unreachable") == (panel$q_sofar + panel$remaining < RULE_GAMES)), "unreachable <=> cannot reach 65")
last_rows <- panel %>% group_by(season, athlete_id) %>% slice_max(player_game_no, n = 1) %>% ungroup()
q_mismatch <- last_rows %>% filter(q_thru != qualifying_games_season) %>%
  select(season, athlete_name, n_stints, q_thru, qualifying_games_season)
if (nrow(q_mismatch)) { cat("  player-seasons whose running count misses the season total (trade-day overlaps):\n"); pr(q_mismatch) }
check(nrow(q_mismatch) <= 5, "running qualifying count ends at the season total for all but <= 5 player-seasons")
check(all(!is.na(panel$national_tv)), "national_tv attached for every panel game")
check(all(!is.na(panel$healthy_rows[panel$has_row])), "rows-only healthy flag defined on every ESPN row")

cat("\n  Panel rows by season, group and absence type:\n")
pr(panel %>% count(season, group, absence_type) %>% pivot_wider(names_from = c(group, absence_type), values_from = n))

# --- 3b. Coverage of absences by ESPN DNP rows (a property of the source; data-section table)
dnp_coverage <- panel %>%
  filter(!covid, group != "current_def_only") %>%
  group_by(season, group) %>%
  summarise(team_games = n(), absences = sum(!played), dnp_rows = sum(!played & has_row), no_rows = sum(!played & !has_row),
            absence_rate = absences / team_games, share_absences_with_dnp_row = dnp_rows / absences, .groups = "drop")
cat("\n  Share of absences that appear as an ESPN DNP row, by season and group:\n")
pr(dnp_coverage %>% select(season, group, absences, share_absences_with_dnp_row) %>%
     pivot_wider(names_from = group, values_from = c(absences, share_absences_with_dnp_row)) %>%
     mutate(across(starts_with("share"), ~ round(.x, 2))))
check(all(dnp_coverage$share_absences_with_dnp_row < 0.6), "no season has DNP rows for more than 60% of absences (source property)")
write_csv(dnp_coverage, "results/tables/dnp_row_coverage.csv")
write_rds(dnp_coverage, "data/derived/dnp_row_coverage.rds")

cat("\n  Healthy late-season STAR player-games by state, pre vs post, FULL SCHEDULE:\n")
pr(panel %>% filter(star_ppp, !covid, healthy, late_season) %>%
     count(post_rule, state) %>% pivot_wider(names_from = post_rule, values_from = n, names_prefix = "post_"))
cat("  Rows-only replication (findings sec. 5: reachable 3380/1342, secured 1711/573, unreachable 1363/459):\n")
pr(panel %>% filter(star_ppp, !covid, has_row, healthy_rows, late_season) %>%
     count(post_rule, state) %>% pivot_wider(names_from = post_rule, values_from = n, names_prefix = "post_"))
cat("\n  Absence rate of healthy late-season stars by state, pre vs post, FULL SCHEDULE (rows-only in findings: .029/.026, .058/.021, .073/.026):\n")
pr(panel %>% filter(star_ppp, !covid, healthy, late_season) %>%
     group_by(post_rule, state) %>% summarise(n = n(), sat = round(mean(sat), 3), .groups = "drop") %>%
     pivot_wider(names_from = post_rule, values_from = c(n, sat)))

write_rds(panel, "data/derived/player_game_panel.rds")
cat("  saved data/derived/player_game_panel.rds (", nrow(panel), " rows, ", sum(panel$has_row), " with an ESPN row)\n", sep = "")


# -----------------------------------------------------------------------------
# 4. CURRENT-SEASON CONTENTION PROXY
#    Top-30 in pts+reb+ast per game through team game 62, among players with
#    40+ games played by then. Needs the raw box for the counting stats.
# -----------------------------------------------------------------------------
stage("STAGE 4: current-season contention proxy")

raw_stats <- read_rds("data/raw/player_box_raw.rds") %>%
  filter(season_type == 2) %>%
  transmute(game_id = as.character(game_id), athlete_id = as.character(athlete_id), team_id = as.character(team_id),
            pra = points + rebounds + assists) %>%
  distinct(game_id, athlete_id, .keep_all = TRUE)

contention <- box_reg %>%
  filter(team_game_no <= AT_RISK_GAME) %>%
  left_join(raw_stats, by = c("game_id", "athlete_id", "team_id")) %>%
  group_by(season, athlete_id) %>%
  summarise(gp_thru_62 = sum(played),
            pra_pg_thru_62 = if_else(gp_thru_62 > 0, sum(pra[played], na.rm = TRUE) / gp_thru_62, NA_real_),
            .groups = "drop") %>%
  group_by(season) %>%
  mutate(eligible = gp_thru_62 >= 40,
         pra_rank = NA_real_,
         pra_rank = replace(pra_rank, eligible, rank(-pra_pg_thru_62[eligible], ties.method = "first")),
         contender_cur = !is.na(pra_rank) & pra_rank <= 30) %>%
  ungroup()

rm(raw_stats); invisible(gc())

check(all(contention %>% group_by(season) %>% summarise(n = sum(contender_cur)) %>% pull(n) == 30),
      "exactly 30 current-season contenders per season")
cat("\n  Overlap of the current-season proxy with the lagged star and contender flags:\n")
pr(contention %>% filter(contender_cur) %>%
     inner_join(player_season_clean %>% select(season, athlete_id, star_ppp, contender), by = c("season", "athlete_id")) %>%
     group_by(season) %>% summarise(n = n(), share_star = round(mean(star_ppp), 2), share_contender = round(mean(contender), 2),
                                    min_pra = round(min(pra_pg_thru_62), 1), .groups = "drop"))

write_rds(contention, "data/derived/contention_proxy.rds")
cat("  saved data/derived/contention_proxy.rds\n")


# -----------------------------------------------------------------------------
# 5. AT-RISK TABLE: slack at team game 62
# -----------------------------------------------------------------------------
stage("STAGE 5: at-risk table")

slack_bins <- function(x) cut(x, c(-1, 2, 5, 8), labels = c("0-2", "3-5", "6-8"))

# 5a. Legacy replication: exactly the exploratory definitions (naive game index,
#     >= 20 min only through game 62, 20 games assumed left, reached from
#     player_season.rds). This should reproduce findings section 2.
at_risk_legacy <- player_box %>%
  inner_join(game_idx_legacy %>% select(game_id, team_id, team_game_no, team_games), by = c("game_id", "team_id")) %>%
  filter(team_game_no <= AT_RISK_GAME) %>%
  group_by(season, athlete_id) %>%
  summarise(q_thru_62 = sum(played & minutes >= RULE_MIN), .groups = "drop") %>%
  inner_join(player_season %>% select(season, athlete_id, qualifying_games, star_ppp, contender),
             by = c("season", "athlete_id")) %>%
  filter(star_ppp, !season %in% COVID_SEASONS) %>%
  mutate(post_rule = season %in% POST_SEASONS,
         slack_at_62 = q_thru_62 + 20 - RULE_GAMES, reached = qualifying_games >= RULE_GAMES)

tab_legacy <- at_risk_legacy %>%
  filter(slack_at_62 >= 0, slack_at_62 <= 8) %>%
  group_by(contender, slack_bin = slack_bins(slack_at_62), post_rule) %>%
  summarise(n = n(), reached = round(mean(reached), 2), .groups = "drop") %>%
  pivot_wider(names_from = post_rule, values_from = c(n, reached)) %>%
  rename(n_pre = n_FALSE, n_post = n_TRUE, reached_pre = reached_FALSE, reached_post = reached_TRUE) %>%
  arrange(contender, slack_bin)
cat("\n  (A) Legacy replication of findings section 2 (expect n pre 15/13/17/10/15/13, post 4/8/8/5/3/7):\n")
pr(tab_legacy)
write_csv(tab_legacy, "results/tables/at_risk_legacy_replication.csv")

# 5b. Clean version: regular-season games only, rule definition of qualifying
#     games, actual games remaining, healthy at 62, current-season contention.
at_risk <- panel %>%
  filter(star_ppp, !covid, team_game_no <= AT_RISK_GAME) %>%
  group_by(season, athlete_id, athlete_name, post_rule, contender) %>%
  summarise(
    games_thru_62     = n(),
    q_thru_62         = sum(qual20) + pmin(sum(qual15), RULE_LOW_ALLOW),
    q_thru_62_strict  = sum(qual20),
    games_left        = last(team_games) - AT_RISK_GAME,                 # 20 for an 82-game team
    played_60_62      = sum(played[team_game_no >= AT_RISK_GAME - 2]),    # games 60, 61, 62
    games_60_62       = sum(team_game_no >= AT_RISK_GAME - 2),
    .groups = "drop"
  ) %>%
  inner_join(player_season_clean %>% select(season, athlete_id, qualifying_games, games_played), by = c("season", "athlete_id")) %>%
  left_join(contention %>% select(season, athlete_id, contender_cur, pra_pg_thru_62, gp_thru_62), by = c("season", "athlete_id")) %>%
  mutate(contender_cur  = replace_na(contender_cur, FALSE),
         slack_at_62    = q_thru_62 + games_left - RULE_GAMES,
         secured_at_62  = q_thru_62 >= RULE_GAMES,
         reached        = qualifying_games >= RULE_GAMES,
         healthy_at_62  = played_60_62 >= 2,
         at_risk        = slack_at_62 >= 0 & slack_at_62 <= 8,
         slack_bin      = slack_bins(slack_at_62))

check(!any(duplicated(at_risk[c("season", "athlete_id")])), "at_risk unique on season x athlete_id")
check(all(at_risk$reached[at_risk$secured_at_62]), "everyone secured at game 62 reached 65")
check(all(!at_risk$reached[at_risk$slack_at_62 < 0]), "nobody with negative slack at game 62 reached 65")

cat("\n  Star-seasons by eligibility position at team game 62 (clean definitions):\n")
pr(at_risk %>% mutate(pos = case_when(secured_at_62 ~ "secured", slack_at_62 < 0 ~ "unreachable",
                                      slack_at_62 <= 8 ~ "at risk (slack 0-8)", TRUE ~ "comfortable (slack 9+)")) %>%
     count(season, pos) %>% pivot_wider(names_from = pos, values_from = n, values_fill = 0))

# (B) Clean counterpart of the legacy table: same cells, corrected data.
tab_clean <- at_risk %>% filter(at_risk) %>%
  group_by(contender, slack_bin, post_rule) %>%
  summarise(n = n(), reached = round(mean(reached), 2), .groups = "drop") %>%
  pivot_wider(names_from = post_rule, values_from = c(n, reached)) %>%
  rename(n_pre = n_FALSE, n_post = n_TRUE, reached_pre = reached_FALSE, reached_post = reached_TRUE) %>%
  arrange(contender, slack_bin)
cat("\n  (B) Same table on clean data (regular-season games only, rule definition of qualifying games):\n")
pr(tab_clean)
write_csv(tab_clean, "results/tables/at_risk_clean.csv")

# (C) Add the healthy-at-62 condition.
tab_healthy <- at_risk %>% filter(at_risk) %>%
  group_by(healthy_at_62, contender, slack_bin, post_rule) %>%
  summarise(n = n(), reached = round(mean(reached), 2), .groups = "drop") %>%
  pivot_wider(names_from = post_rule, values_from = c(n, reached), values_fill = list(n = 0L)) %>%
  rename(n_pre = n_FALSE, n_post = n_TRUE, reached_pre = reached_FALSE, reached_post = reached_TRUE) %>%
  arrange(desc(healthy_at_62), contender, slack_bin)
cat("\n  (C) By healthy at game 62 (played 2 of games 60-62) x prior-season contender x slack bin:\n")
pr(tab_healthy)
write_csv(tab_healthy, "results/tables/at_risk_by_health.csv")

# (D) Healthy at 62, current-season contention proxy instead of the lagged flag.
tab_cur <- at_risk %>% filter(at_risk, healthy_at_62) %>%
  group_by(contender_cur, slack_bin, post_rule) %>%
  summarise(n = n(), reached = round(mean(reached), 2), .groups = "drop") %>%
  pivot_wider(names_from = post_rule, values_from = c(n, reached), values_fill = list(n = 0L)) %>%
  rename(n_pre = n_FALSE, n_post = n_TRUE, reached_pre = reached_FALSE, reached_post = reached_TRUE) %>%
  arrange(contender_cur, slack_bin)
cat("\n  (D) Healthy at 62 only, by current-season contention proxy (top-30 pts+reb+ast through game 62) x slack bin:\n")
pr(tab_cur)
write_csv(tab_cur, "results/tables/at_risk_healthy_by_current_contention.csv")

# (E) Compact: healthy at-risk stars pooled over contention, by slack bin.
tab_pooled <- at_risk %>% filter(at_risk) %>%
  group_by(healthy_at_62, slack_bin, post_rule) %>%
  summarise(n = n(), reached = round(mean(reached), 2), .groups = "drop") %>%
  pivot_wider(names_from = post_rule, values_from = c(n, reached), values_fill = list(n = 0L)) %>%
  rename(n_pre = n_FALSE, n_post = n_TRUE, reached_pre = reached_FALSE, reached_post = reached_TRUE) %>%
  arrange(desc(healthy_at_62), slack_bin)
cat("\n  (E) Pooled over contention, by healthy at 62 x slack bin:\n")
pr(tab_pooled)
write_csv(tab_pooled, "results/tables/at_risk_pooled.csv")

# (F) Per-season at-risk counts: the inputs to the bounding argument (findings sec. 9).
per_season <- at_risk %>%
  group_by(season, post_rule) %>%
  summarise(stars = n(), n_at_risk = sum(at_risk), n_at_risk_healthy = sum(at_risk & healthy_at_62),
            n_at_risk_reached = sum(at_risk & reached), n_at_risk_healthy_reached = sum(at_risk & healthy_at_62 & reached),
            n_at_risk_cur_contender = sum(at_risk & contender_cur), .groups = "drop")
check(all(per_season$n_at_risk_healthy <= per_season$n_at_risk), "healthy at-risk count never exceeds at-risk count")
cat("\n  (F) At-risk star-seasons (slack 0-8 at game 62) per season:\n")
pr(per_season)
write_csv(per_season, "results/tables/at_risk_per_season.csv")

write_rds(at_risk, "data/derived/at_risk.rds")
write_csv(at_risk, "data/derived/at_risk.csv")
cat("  saved data/derived/at_risk.rds (", nrow(at_risk), " star-seasons)\n", sep = "")


# -----------------------------------------------------------------------------
# 6. SUMMARY
# -----------------------------------------------------------------------------
stage("STAGE 6: summary")
cat("  data/derived/game_idx.rds            ", nrow(game_idx), "team-games\n")
cat("  data/derived/excluded_games.rds      ", nrow(excluded_games), "team-games removed\n")
cat("  data/derived/player_season_clean.rds ", nrow(player_season_clean), "player-seasons\n")
cat("  data/derived/player_game_panel.rds   ", nrow(panel), "player-games\n")
cat("  data/derived/contention_proxy.rds    ", nrow(contention), "player-seasons\n")
cat("  data/derived/at_risk.rds             ", nrow(at_risk), "star-seasons\n")
cat("  results/tables/at_risk_*.csv, star_counts_orig_vs_clean.csv\n")
cat("\nDone.\n")
