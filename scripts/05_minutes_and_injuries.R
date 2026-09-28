# =============================================================================
# 05_minutes_and_injuries.R
#
# NBA 65-game rule: two descriptive tables
#
#   1. H4 minute bins: late-season stars who played, by whether they were
#      "tight" (slack 0-3, not yet secured), pre vs post, with cell counts.
#      A second version drops recent returners (played each of the previous
#      three games) to blunt the minute-restriction confound.
#   2. Long absences: spells of 10+ consecutive missed games by stars, their
#      timing within the season, length, censoring at season end, and the
#      DNP reason at the start of the spell; pre vs post.
#
# Inputs:  data/derived/player_game_panel.rds
# Outputs: data/derived/minutes_tables.rds, long_absences.rds;
#          results/tables/minutes_*.csv, absences_*.csv; results/figures/absence_timing.*
# =============================================================================


# -----------------------------------------------------------------------------
# 0. SETUP
# -----------------------------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse)
})

PROJECT_ROOT <- "/Users/maddockl/nba-65-game-rule"
setwd(PROJECT_ROOT)

SEASONS        <- 2014:2026
COVID_SEASONS  <- c(2020, 2021)
POST_SEASONS   <- 2024:2026
EST_SEASONS    <- setdiff(SEASONS, COVID_SEASONS)
RULE_GAMES     <- 65
LONG_SPELL     <- 10
LATE_GAME      <- 55

stage <- function(txt) cat("\n", strrep("=", 78), "\n", txt, "\n", strrep("=", 78), "\n", sep = "")
check <- function(cond, msg) {
  if (!isTRUE(cond)) stop("CHECK FAILED: ", msg, call. = FALSE)
  cat("  ok:", msg, "\n")
}
pr <- function(x, ...) print(x, n = Inf, width = Inf, ...)

panel <- read_rds("data/derived/player_game_panel.rds")
check(all(c("tight", "min_bin", "played_prev3", "late_season", "reason", "player_game_no") %in% names(panel)),
      "panel has required columns")


# -----------------------------------------------------------------------------
# 1. H4: MINUTE BINS OF LATE-SEASON STARS WHO PLAYED
# -----------------------------------------------------------------------------
stage("STAGE 1: minute bins")

h4 <- panel %>%
  filter(star_ppp, !covid, played, late_season) %>%
  mutate(period = if_else(post_rule, "post", "pre"),
         cell = paste(period, if_else(tight, "tight", "not tight"), sep = ", "),
         cell = factor(cell, levels = c("pre, not tight", "pre, tight", "post, not tight", "post, tight")),
         no_recent_return = played_prev3 == 3)
check(all(levels(h4$min_bin) == c("<15", "15-19", "20-22", "23-30", "31+")), "minute bins as in findings sec. 8")

min_table <- function(d) {
  counts <- d %>% count(cell, min_bin) %>% complete(cell, min_bin, fill = list(n = 0L)) %>%
    group_by(cell) %>% mutate(share = n / sum(n), cell_n = sum(n)) %>% ungroup()
  shares <- counts %>% select(min_bin, cell, share) %>% pivot_wider(names_from = cell, values_from = share)
  ns     <- counts %>% select(min_bin, cell, n) %>% pivot_wider(names_from = cell, values_from = n, names_prefix = "n_")
  totals <- counts %>% distinct(cell, cell_n) %>% pivot_wider(names_from = cell, values_from = cell_n) %>% mutate(min_bin = "player-games")
  players <- d %>% group_by(cell) %>% summarise(k = n_distinct(athlete_id), .groups = "drop") %>%
    pivot_wider(names_from = cell, values_from = k) %>% mutate(min_bin = "players")
  list(shares = shares, counts = ns, totals = totals, players = players, long = counts)
}

h4_all <- min_table(h4)
h4_nrr <- min_table(h4 %>% filter(no_recent_return))

cat("\n  Share of late-season star player-games by minute bin (findings sec. 8: post tight 20-22 .054, 23-30 .358, 31+ .579):\n")
pr(h4_all$shares %>% mutate(across(-min_bin, ~ round(.x, 3))))
cat("  Cell counts (player-games):\n"); pr(h4_all$counts)
cat("  Player-games and distinct players per cell:\n"); pr(bind_rows(h4_all$totals, h4_all$players))

cat("\n  Same, excluding players who did not play each of the previous three games (no recent return):\n")
pr(h4_nrr$shares %>% mutate(across(-min_bin, ~ round(.x, 3))))
cat("  Cell counts:\n"); pr(h4_nrr$counts)
cat("  Player-games and distinct players per cell:\n"); pr(bind_rows(h4_nrr$totals, h4_nrr$players))

# Mean minutes and share in 20-30 by cell, with simple SEs, as a compact summary
min_summary <- bind_rows(
  h4 %>% mutate(sample = "all"),
  h4 %>% filter(no_recent_return) %>% mutate(sample = "no recent return")
) %>%
  group_by(sample, cell) %>%
  summarise(n = n(), players = n_distinct(athlete_id), mean_minutes = mean(minutes),
            share_20_30 = mean(minutes >= 20 & minutes <= 30), se_20_30 = sqrt(share_20_30 * (1 - share_20_30) / n),
            share_31plus = mean(minutes >= 31), .groups = "drop")
cat("\n  Summary by cell:\n")
pr(min_summary %>% mutate(across(c(mean_minutes, share_20_30, se_20_30, share_31plus), ~ round(.x, 3))))

post_tight_n <- h4_all$totals[["post, tight"]]
check(post_tight_n >= 100 && post_tight_n <= 400, "post-rule tight cell is small (100-400 player-games), as in findings sec. 8")
check(h4_all$shares %>% filter(min_bin == "23-30") %>% pull(`post, tight`) >
        h4_all$shares %>% filter(min_bin == "23-30") %>% pull(`pre, tight`),
      "post-rule tight stars have a larger 23-30 minute share than pre-rule tight stars (the suggestive H4 pattern)")

write_rds(list(all = h4_all, no_recent_return = h4_nrr, summary = min_summary), "data/derived/minutes_tables.rds")
write_csv(h4_all$long, "results/tables/minutes_bins_long.csv")
write_csv(h4_nrr$long, "results/tables/minutes_bins_no_recent_return_long.csv")
write_csv(min_summary, "results/tables/minutes_summary.csv")


# -----------------------------------------------------------------------------
# 1b. SHARE OF APPEARANCES OF 20+ MINUTES: STARS VS LAGGED CONTROL
# -----------------------------------------------------------------------------
stage("STAGE 1b: 20-minute share of appearances, stars vs control")
suppressPackageStartupMessages(library(fixest))
MDE_K <- qnorm(0.975) + qnorm(0.80)
m20 <- panel %>% filter(!covid, played, group != "current_def_only", season >= 2015) %>%
  mutate(q20 = as.numeric(minutes >= 20), star = as.numeric(star_ppp), post = as.numeric(post_rule), rel = factor(season, levels = setdiff(2015:2026, 2020:2021)))
share20_raw <- m20 %>% group_by(season, group) %>% summarise(n = n(), share20 = mean(q20), .groups = "drop") %>% pivot_wider(names_from = group, values_from = c(n, share20))
cat("\n  Share of appearances lasting 20+ minutes, by season and group:\n"); pr(share20_raw %>% mutate(across(starts_with("share"), ~ round(.x, 3))))
tidy20 <- function(m, lab) as_tibble(coeftable(m), rownames = "term") %>% filter(str_detect(term, "^rel::|post:star")) %>%
  transmute(sample = lab, term, season = as.integer(str_extract(term, "(?<=::)\\d{4}")), est = Estimate, se = `Std. Error`, p = `Pr(>|t|)`, lo = est - 1.96 * se, hi = est + 1.96 * se, mde = MDE_K * se)
m20_models <- list(
  es_all   = feols(q20 ~ i(rel, star, ref = "2023") | athlete_id + season + team_game_no, m20, cluster = ~athlete_id),
  pool_all = feols(q20 ~ post:star | athlete_id + season + team_game_no, m20, cluster = ~athlete_id),
  es_late  = feols(q20 ~ i(rel, star, ref = "2023") | athlete_id + season + team_game_no, m20 %>% filter(late_season), cluster = ~athlete_id),
  pool_late = feols(q20 ~ post:star | athlete_id + season + team_game_no, m20 %>% filter(late_season), cluster = ~athlete_id)
)
share20_es <- bind_rows(tidy20(m20_models$es_all, "all games"), tidy20(m20_models$pool_all, "all games"),
                        tidy20(m20_models$es_late, "late season"), tidy20(m20_models$pool_late, "late season"))
cat("\n  Event study and pooled DiD, share of appearances of 20+ minutes (star minus control, ref 2023):\n")
pr(share20_es %>% mutate(across(c(est, se, p, lo, hi, mde), ~ round(.x, 4))))
write_csv(share20_raw, "results/tables/minutes_share20_raw.csv"); write_csv(share20_es, "results/tables/minutes_share20_es.csv")

# --- 1c. Does the player-FE estimate reconcile with the raw series? -------------------------------
# Raw difference-in-differences against three pre-periods; the pooled estimate with and without
# player fixed effects; never-switchers (players who are always stars or always controls); a
# star-specific linear trend; and an event study without player fixed effects.
m20 <- m20 %>% mutate(ps = post * star, trend = season - 2023, star_trend = star * trend)
switch_status <- m20 %>% distinct(athlete_id, season, star) %>% group_by(athlete_id) %>% summarise(switcher = max(star) == 1 & min(star) == 0, .groups = "drop")
m20 <- m20 %>% left_join(switch_status, by = "athlete_id")
raw_did <- function(d, lab) { r <- d %>% group_by(star, post) %>% summarise(s = mean(q20), .groups = "drop")
  tibble(pre_period = lab, star_pre = r$s[r$star == 1 & r$post == 0], star_post = r$s[r$star == 1 & r$post == 1],
         ctrl_pre = r$s[r$star == 0 & r$post == 0], ctrl_post = r$s[r$star == 0 & r$post == 1]) %>%
    mutate(raw_did = (star_post - star_pre) - (ctrl_post - ctrl_pre)) }
share20_rawdid <- bind_rows(raw_did(m20, "2015-2023"), raw_did(m20 %>% filter(season >= 2022), "2022-2023"), raw_did(m20 %>% filter(season >= 2023), "2023"))
spec_row <- function(m, lab) { c <- coeftable(m); tibble(spec = lab, est = c["ps", 1], se = c["ps", 2], p = c["ps", 4], mde = MDE_K * c["ps", 2], n = nobs(m)) }
share20_specs <- bind_rows(
  spec_row(feols(q20 ~ ps | athlete_id + season + team_game_no, m20, cluster = ~athlete_id), "Player, season and game-number FE"),
  spec_row(feols(q20 ~ star + ps | season + team_game_no, m20, cluster = ~athlete_id), "No player FE (star indicator, season and game-number FE)"),
  spec_row(feols(q20 ~ ps | athlete_id + season + team_game_no, m20 %>% filter(!switcher), cluster = ~athlete_id), "Never-switchers, player FE"),
  spec_row(feols(q20 ~ star + ps | season + team_game_no, m20 %>% filter(!switcher), cluster = ~athlete_id), "Never-switchers, no player FE"),
  spec_row(feols(q20 ~ ps | athlete_id + season + team_game_no, m20 %>% filter(season >= 2022), cluster = ~athlete_id), "2022-2026 only, player FE"),
  spec_row(feols(q20 ~ star + ps | season + team_game_no, m20 %>% filter(season >= 2022), cluster = ~athlete_id), "2022-2026 only, no player FE"),
  spec_row(feols(q20 ~ star_trend + ps | athlete_id + season + team_game_no, m20, cluster = ~athlete_id), "Player FE plus star-specific linear trend"),
  spec_row(feols(q20 ~ star + star_trend + ps | season + team_game_no, m20, cluster = ~athlete_id), "No player FE plus star-specific linear trend"))
es_nofe <- feols(q20 ~ star + i(rel, star, ref = "2023") | season + team_game_no, m20, cluster = ~athlete_id)
share20_es_nofe <- as_tibble(coeftable(es_nofe), rownames = "term") %>% filter(str_detect(term, "^rel::")) %>%
  transmute(season = as.integer(str_extract(term, "(?<=::)\\d{4}")), est = Estimate, se = `Std. Error`, p = `Pr(>|t|)`, mde = MDE_K * se)
sub20 <- m20 %>% group_by(season, group, athlete_id) %>% summarise(n_sub20 = sum(q20 == 0), apps = n(), .groups = "drop")
sub20_season <- sub20 %>% group_by(season, group) %>% summarise(player_seasons = n(), sub20_per_player_season = mean(n_sub20), apps_per_player_season = mean(apps), .groups = "drop")
sub20_period <- sub20 %>% mutate(period = case_when(season >= 2024 ~ "post", season == 2023 ~ "2023", TRUE ~ "2015-2022")) %>%
  group_by(group, period) %>% summarise(player_seasons = n(), sub20_per_player_season = mean(n_sub20), .groups = "drop")
cat("\n  Raw difference-in-differences in the 20+ minute share, by choice of pre-period:\n"); pr(share20_rawdid %>% mutate(across(where(is.double), ~ round(.x, 4))))
cat("\n  Pooled post x star under alternative specifications:\n"); pr(share20_specs %>% mutate(across(c(est, se, p, mde), ~ round(.x, 4))))
cat("\n  Event study without player fixed effects, ref 2023:\n"); pr(share20_es_nofe %>% mutate(across(where(is.double), ~ round(.x, 4))))
cat("\n  Appearances under 20 minutes per player-season:\n"); pr(sub20_period %>% mutate(sub20_per_player_season = round(sub20_per_player_season, 2)))
cat("  switchers:", sum(switch_status$switcher), "of", nrow(switch_status), "players\n")
check(abs(share20_rawdid$raw_did[share20_rawdid$pre_period == "2023"]) < 0.015, "raw DiD against 2023 alone is under 1.5 points (the levels do not show a break at the rule)")
write_csv(share20_rawdid, "results/tables/minutes_share20_raw_did.csv"); write_csv(share20_specs, "results/tables/minutes_share20_specs.csv")
write_csv(share20_es_nofe, "results/tables/minutes_share20_es_nofe.csv"); write_csv(sub20_season, "results/tables/minutes_sub20_by_season.csv"); write_csv(sub20_period, "results/tables/minutes_sub20_by_period.csv")
write_rds(m20_models, "data/derived/minutes_share20_models.rds")


# -----------------------------------------------------------------------------
# 2. LONG ABSENCES: 10+ CONSECUTIVE MISSED GAMES BY STARS
# -----------------------------------------------------------------------------
stage("STAGE 2: long absences")

classify_reason <- function(r) {
  r <- str_to_lower(coalesce(r, ""))
  case_when(
    str_detect(r, "rest|load|maintenance|management")               ~ "rest",
    str_detect(r, "coach")                                          ~ "coach's decision",
    str_detect(r, "personal|suspen|trade|not with|league|conditioning|health and safety|protocol|bereav|family|birth") ~ "other",
    TRUE                                                            ~ "injury or illness"
  )
}

# Spells run over the full team schedule (02): an absence is a missing row or a DNP row.
# The reason is known only for games with a row; spells are classified by the first row-bearing
# absence inside the spell, if any.
spells <- panel %>%
  filter(!covid, group != "current_def_only") %>%
  arrange(season, athlete_id, player_game_no) %>%
  group_by(season, athlete_id, athlete_name, post_rule, group) %>%
  mutate(run_id = cumsum(sat != lag(sat, default = first(sat)))) %>%
  group_by(season, athlete_id, athlete_name, post_rule, group, run_id) %>%
  summarise(sat = first(sat), length = n(),
            start_game = first(team_game_no), end_game = last(team_game_no),
            start_player_game = first(player_game_no), end_player_game = last(player_game_no),
            games_with_row = sum(has_row),
            first_reason = if (any(has_row)) first(reason[has_row]) else NA_character_,
            reason_class = if (any(has_row)) classify_reason(first(reason[has_row])) else "no row (reason unknown)",
            q_at_start = first(q_sofar), slack_at_start = first(slack), in_row_span = first(in_row_span),
            .groups = "drop") %>%
  filter(sat, length >= LONG_SPELL) %>%
  left_join(panel %>% group_by(season, athlete_id) %>% summarise(last_pg = max(player_game_no), .groups = "drop"),
            by = c("season", "athlete_id")) %>%
  mutate(censored = end_player_game == last_pg,
         starts_before_first_row = !in_row_span & start_player_game == 1,
         start_bin = cut(start_game, c(0, 20, 40, 55, 82), labels = c("games 1-20", "21-40", "41-55", "56-82")),
         state_at_start = case_when(q_at_start >= RULE_GAMES ~ "secured", slack_at_start >= 0 ~ "reachable", TRUE ~ "unreachable"))

check(all(spells$length >= LONG_SPELL), "all spells have 10+ missed games")
check(all(spells$start_game <= spells$end_game), "spell start precedes end")

cat("\n  Reason strings on the first row-bearing game of long spells (top 15):\n")
pr(spells %>% filter(!is.na(first_reason)) %>% count(first_reason, sort = TRUE) %>% head(15))
cat("\n  Reason classes (spells with no ESPN row anywhere have no reason):\n"); pr(spells %>% count(post_rule, reason_class))
cat("  Spells that begin at team game 1 before the player's first ESPN row (start of season absences):",
    sum(spells$starts_before_first_row), "\n")

star_seasons <- panel %>% filter(!covid, group != "current_def_only") %>% distinct(season, athlete_id, post_rule, group) %>%
  count(post_rule, group, name = "star_seasons")

absence_summary <- spells %>%
  group_by(post_rule, group) %>%
  summarise(spells = n(), star_seasons_with_spell = n_distinct(paste(season, athlete_id)),
            mean_length = mean(length), median_length = median(length), total_games_missed = sum(length),
            share_censored = mean(censored), share_injury = mean(reason_class == "injury or illness"),
            share_no_reason = mean(reason_class == "no row (reason unknown)"),
            share_rest_or_coach = mean(reason_class %in% c("rest", "coach's decision")),
            share_start_1_20 = mean(start_bin == "games 1-20"), share_start_21_40 = mean(start_bin == "21-40"),
            share_start_41_55 = mean(start_bin == "41-55"), share_start_56_82 = mean(start_bin == "56-82"),
            share_reachable_at_start = mean(state_at_start == "reachable"),
            .groups = "drop") %>%
  inner_join(star_seasons, by = c("post_rule", "group")) %>%
  mutate(spells_per_star_season = spells / star_seasons,
         share_star_seasons_with_spell = star_seasons_with_spell / star_seasons,
         games_missed_per_star_season = total_games_missed / star_seasons) %>%
  mutate(period = if_else(post_rule, "post", "pre")) %>%
  select(group, period, star_seasons, spells, spells_per_star_season, share_star_seasons_with_spell,
         mean_length, median_length, games_missed_per_star_season, share_censored, share_injury, share_no_reason,
         share_rest_or_coach, starts_with("share_start"), share_reachable_at_start)
cat("\n  Long absences (10+ consecutive missed games), stars and high-minute non-stars, pre vs post:\n")
pr(absence_summary %>% mutate(across(where(is.double), ~ round(.x, 3))))

absence_by_season <- spells %>%
  group_by(season, group) %>%
  summarise(spells = n(), mean_length = mean(length), games_missed = sum(length),
            share_injury = mean(reason_class == "injury or illness"), share_start_56_82 = mean(start_bin == "56-82"), .groups = "drop") %>%
  right_join(panel %>% filter(!covid, group != "current_def_only") %>% distinct(season, athlete_id, group) %>% count(season, group, name = "star_seasons"), by = c("season", "group")) %>%
  mutate(across(c(spells, games_missed), ~ replace_na(.x, 0L)),
         spells_per_star_season = spells / star_seasons, games_missed_per_star_season = games_missed / star_seasons) %>%
  arrange(group, season)
cat("\n  By season:\n")
pr(absence_by_season %>% mutate(across(where(is.double), ~ round(.x, 3))))

timing <- spells %>% count(group, post_rule, start_bin) %>% complete(group, post_rule, start_bin, fill = list(n = 0L)) %>%
  group_by(group, post_rule) %>% mutate(share = n / sum(n)) %>% ungroup() %>%
  mutate(period = if_else(post_rule, "post", "pre")) %>% select(group, period, start_bin, n, share)
cat("\n  Timing of spell starts:\n"); pr(timing %>% mutate(share = round(share, 3)))

check(all(absence_summary$share_rest_or_coach < 0.15), "long spells coded rest or coach's decision are a small minority (< 15%)")
check(sum(spells$group == "star") > 100, "star long spells number in the hundreds on the full schedule (13 on ESPN rows alone)")
# Did the post-rule rise in long spells differ between stars and non-stars?
spell_rise <- absence_summary %>% select(group, period, spells_per_star_season, share_start_56_82) %>%
  pivot_wider(names_from = period, values_from = c(spells_per_star_season, share_start_56_82)) %>%
  mutate(ratio_spells = spells_per_star_season_post / spells_per_star_season_pre)
cat("\n  Post/pre ratio of spells per player-season by group:\n"); pr(spell_rise %>% mutate(across(where(is.double), ~ round(.x, 3))))
write_csv(spell_rise, "results/tables/absences_rise_by_group.csv")

# Late-onset test: share of spells beginning at team game 56+, pre vs post, stars and control;
# Fisher exact tests and a difference-in-shares with a bootstrap interval (resampling spells within group x period)
late <- spells %>% mutate(late_onset = start_game > LATE_GAME, period = if_else(post_rule, "post", "pre"))
cell <- late %>% group_by(group, period) %>% summarise(n = n(), n_late = sum(late_onset), share = mean(late_onset), .groups = "drop")
fish <- late %>% group_by(group) %>% summarise(p_fisher = fisher.test(table(post_rule, late_onset))$p.value, .groups = "drop")
dd_point <- function(d) { s <- d %>% group_by(group, period) %>% summarise(sh = mean(late_onset), .groups = "drop")
  (s$sh[s$group == "star" & s$period == "post"] - s$sh[s$group == "star" & s$period == "pre"]) -
  (s$sh[s$group == "high_minute_nonstar" & s$period == "post"] - s$sh[s$group == "high_minute_nonstar" & s$period == "pre"]) }
set.seed(20260916)
boot_dd <- replicate(2000, dd_point(late %>% group_by(group, period) %>% slice_sample(prop = 1, replace = TRUE) %>% ungroup()))
late_test <- list(cells = cell %>% left_join(fish, by = "group"),
                  dd = tibble(stat = "difference in late-onset shares, stars minus control, post minus pre", est = dd_point(late),
                              lo = quantile(boot_dd, 0.025), hi = quantile(boot_dd, 0.975), se_boot = sd(boot_dd)))
cat("\n  Late-onset (game 56+) share of long spells, with Fisher p-values:\n"); pr(late_test$cells %>% mutate(across(c(share, p_fisher), ~ round(.x, 3))))
cat("  Difference in shares (stars minus control, post minus pre), bootstrap 95% CI:\n"); pr(late_test$dd %>% mutate(across(where(is.double), ~ round(.x, 3))))
write_csv(late_test$cells, "results/tables/absences_late_onset_cells.csv"); write_csv(late_test$dd, "results/tables/absences_late_onset_dd.csv")

write_rds(list(spells = spells, summary = absence_summary, by_season = absence_by_season, timing = timing),
          "data/derived/long_absences.rds")
write_csv(spells, "data/derived/long_absences.csv")
write_csv(absence_summary, "results/tables/absences_summary.csv")
write_csv(absence_by_season, "results/tables/absences_by_season.csv")
write_csv(timing, "results/tables/absences_timing.csv")

# Spell onsets per 100 player-seasons, so stars and non-stars are on the same scale
onset <- spells %>% mutate(start_bin5 = cut(start_game, seq(0, 85, 5), right = TRUE)) %>%
  count(group, post_rule, start_bin5) %>% complete(group, post_rule, start_bin5, fill = list(n = 0L)) %>%
  inner_join(star_seasons, by = c("group", "post_rule")) %>%
  mutate(rate = 100 * n / star_seasons, x = as.numeric(start_bin5) * 5 - 2.5,
         period = factor(if_else(post_rule, "Post-rule: 2024-2026", "Pre-rule: 2014-2019, 2022-2023"),
                         levels = c("Pre-rule: 2014-2019, 2022-2023", "Post-rule: 2024-2026")),
         group = factor(group, levels = c("star", "high_minute_nonstar"), labels = c("Stars", "High-minute non-stars (prior-season status)")))
p_abs <- ggplot(onset, aes(x = x, y = rate, fill = group)) +
  geom_col(position = position_dodge(width = 4.5), width = 4.2) +
  geom_vline(xintercept = 55.5, linetype = "dashed") +
  facet_wrap(~ period, ncol = 1) +
  scale_fill_manual(values = c("firebrick", "grey55")) +
  scale_x_continuous(breaks = seq(0, 80, 10)) +
  labs(x = "Team game at which the absence began", y = "Spells of 10+ missed games per 100 player-seasons", fill = NULL,
       title = "When long absences begin: stars and high-minute non-stars",
       subtitle = "Dashed line: start of the late-season window (game 56)") +
  theme_minimal(base_size = 12) + theme(panel.grid.minor = element_blank(), legend.position = "bottom")
write_csv(onset, "results/tables/absences_onset_rates.csv")
ggsave("results/figures/absence_timing.png", p_abs, width = 8, height = 6, dpi = 200)
write_rds(p_abs, "results/figures/absence_timing.rds")
cat("  saved minutes_*.csv, absences_*.csv, long_absences.rds, absence_timing.png\n")

cat("\nDone.\n")
