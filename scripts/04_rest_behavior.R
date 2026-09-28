# =============================================================================
# 04_rest_behavior.R
#
# NBA 65-game rule: absences of healthy players late in the season
#
# The panel (02) covers every game of a player's team stint(s). ESPN prints a
# box-score row for only a minority of absences (results/tables/dnp_row_coverage.csv),
# so the primary outcome is ABSENCE on the full schedule: sat = did not play,
# whether or not ESPN printed a row. Absence after playing the previous game
# mixes discretionary rest with new injuries; the source cannot separate them.
# A rows-only replication (has_row, healthy_rows) reproduces the exploratory
# numbers in docs/exploratory_findings.md sections 5-7 and is saved alongside.
#
#   1. Healthy late-season stars: absence by eligibility state, pre vs post and
#      by season; split by whether the absence has a DNP row.
#   2. State x post regressions (athlete_id^season + team_game_no FE); the
#      no-incentive gap by season.
#   3. Stars vs high-minute non-stars: raw rates; event studies ref 2023 and
#      ref 2017 (athlete_id + season + team_game_no FE); pooled DiDs. MDEs.
#   4. DNP reasons among the absences that do have a row.
#   5. National-TV footnote (2022-2026 only).
#
# Inputs:  data/derived/player_game_panel.rds
# Outputs: data/derived/rest_models.rds, rest_tables.rds; results/tables/rest_*.csv;
#          results/figures/rest_*.png/.rds
# =============================================================================


# -----------------------------------------------------------------------------
# 0. SETUP
# -----------------------------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse)
  library(fixest)
})

PROJECT_ROOT <- "/Users/maddockl/nba-65-game-rule"
setwd(PROJECT_ROOT)

SEASONS        <- 2014:2026
COVID_SEASONS  <- c(2020, 2021)
POST_SEASONS   <- 2024:2026
EST_SEASONS    <- setdiff(SEASONS, COVID_SEASONS)
MDE_K          <- qnorm(0.975) + qnorm(0.80)

stage <- function(txt) cat("\n", strrep("=", 78), "\n", txt, "\n", strrep("=", 78), "\n", sep = "")
check <- function(cond, msg) {
  if (!isTRUE(cond)) stop("CHECK FAILED: ", msg, call. = FALSE)
  cat("  ok:", msg, "\n")
}
pr <- function(x, ...) print(x, n = Inf, width = Inf, ...)
tidy_terms <- function(m, pattern, ...) {
  as_tibble(coeftable(m), rownames = "term") %>%
    filter(str_detect(term, pattern)) %>%
    transmute(..., term, est = Estimate, se = `Std. Error`, p = `Pr(>|t|)`,
              lo = est - qnorm(0.975) * se, hi = est + qnorm(0.975) * se, mde = MDE_K * se)
}
season_of <- function(term) as.integer(str_extract(term, "(?<=::)\\d{4}"))
r3 <- function(d) d %>% mutate(across(where(is.double), ~ round(.x, 3)))

panel <- read_rds("data/derived/player_game_panel.rds")
check(all(c("has_row", "absence_type", "healthy", "healthy_rows", "late_season", "state", "sat", "star_ppp") %in% names(panel)),
      "panel has required columns")

prep <- function(d) d %>%
  mutate(sat = as.numeric(sat), star = as.numeric(star_ppp), post = as.numeric(post_rule),
         rel = factor(season, levels = EST_SEASONS), no_incentive = as.numeric(state != "reachable"),
         group = if_else(star_ppp, "star", "non-star"))
# Primary: stars and LAGGED high-minute non-stars (group != current_def_only), full schedule.
# Replication: stars and the contemporaneous control, ESPN rows only, as in the exploratory work.
full <- panel %>% filter(!covid, healthy, late_season, group != "current_def_only") %>% prep()
rows <- panel %>% filter(!covid, has_row, healthy_rows, late_season, star_ppp | high_minute_nonstar) %>% prep()
h8   <- full %>% filter(star_ppp)
h8r  <- rows %>% filter(star_ppp)
cat("  healthy late-season player-games, full schedule: stars", nrow(h8), " lagged non-stars", sum(!full$star_ppp),
    "\n  rows-only replication: stars", nrow(h8r), " non-stars", sum(!rows$star_ppp), "\n")


# -----------------------------------------------------------------------------
# 1. ABSENCE BY ELIGIBILITY STATE, HEALTHY LATE-SEASON STARS
# -----------------------------------------------------------------------------
stage("STAGE 1: absence by eligibility state")

state_table <- function(d) d %>%
  group_by(state, post_rule) %>%
  summarise(n = n(), n_players = n_distinct(athlete_id), sat = mean(sat),
            sat_dnp_row = mean(absence_type == "dnp_row"), sat_no_row = mean(absence_type == "no_row"), .groups = "drop") %>%
  mutate(se = sqrt(sat * (1 - sat) / n)) %>%
  pivot_wider(names_from = post_rule, values_from = c(n, n_players, sat, sat_dnp_row, sat_no_row, se)) %>%
  rename_with(~ str_replace(.x, "FALSE", "pre") %>% str_replace("TRUE", "post")) %>%
  mutate(change = sat_post - sat_pre, se_change = sqrt(se_pre^2 + se_post^2))

state_post  <- state_table(h8)
state_postr <- state_table(h8r)
cat("\n  FULL SCHEDULE: absence rate of healthy late-season stars by state, pre vs post:\n")
pr(r3(state_post %>% select(state, n_pre, n_post, sat_pre, sat_post, change, se_change, sat_dnp_row_pre, sat_no_row_pre, sat_dnp_row_post, sat_no_row_post)))
cat("\n  ROWS-ONLY replication (findings sec. 5: .029/.026, .058/.021, .073/.026):\n")
pr(r3(state_postr %>% select(state, n_pre, n_post, sat_pre, sat_post, change, se_change)))

state_season <- h8 %>%
  group_by(season, state) %>% summarise(n = n(), sat = mean(sat), .groups = "drop") %>%
  pivot_wider(names_from = state, values_from = c(n, sat)) %>%
  mutate(gap = (sat_secured * n_secured + sat_unreachable * n_unreachable) / (n_secured + n_unreachable) - sat_reachable)
cat("\n  FULL SCHEDULE: by season and state (gap = no-incentive states minus reachable):\n")
pr(r3(state_season))

check(abs(state_postr$sat_pre[state_postr$state == "secured"] - 0.058) < 0.01 &
        abs(state_postr$sat_post[state_postr$state == "secured"] - 0.021) < 0.01,
      "rows-only replication reproduces the secured-state rates of findings sec. 5")
check(all(state_post$sat_pre > 0.05 & state_post$sat_post > 0.05), "full-schedule absence rates exceed 5% in every state (rest and injury pooled)")
check(state_post$sat_pre[state_post$state == "unreachable"] > 1.5 * state_post$sat_pre[state_post$state == "reachable"] &
        state_post$sat_post[state_post$state == "unreachable"] > 1.5 * state_post$sat_post[state_post$state == "reachable"],
      "the unreachable/reachable gradient is present both before and after the rule")

write_csv(state_post, "results/tables/rest_state_prepost.csv")
write_csv(state_postr, "results/tables/rest_state_prepost_rowsonly.csv")
write_csv(state_season, "results/tables/rest_state_by_season.csv")


# -----------------------------------------------------------------------------
# 2. STATE x POST REGRESSIONS
# -----------------------------------------------------------------------------
stage("STAGE 2: state x post regressions")

fit_state <- function(d) list(
  state_post  = feols(sat ~ i(state, ref = "reachable") + i(state, post, ref = "reachable") | athlete_id^season + team_game_no, d, cluster = ~athlete_id),
  gap_post    = feols(sat ~ no_incentive + no_incentive:post | athlete_id^season + team_game_no, d, cluster = ~athlete_id),
  gap_levels  = feols(sat ~ i(rel, no_incentive) | athlete_id^season + team_game_no, d, cluster = ~athlete_id),
  gap_es_2023 = feols(sat ~ no_incentive + i(rel, no_incentive, ref = "2023") | athlete_id^season + team_game_no, d, cluster = ~athlete_id)
)
rest_models  <- fit_state(h8)
rest_modelsr <- fit_state(h8r)
# exploratory specifications without main effects, rows only, for the replication checks
rest_modelsr$state_post_noME <- feols(sat ~ i(state, post, ref = "reachable") | athlete_id^season + team_game_no, h8r, cluster = ~athlete_id)
rest_modelsr$gap_es_noME     <- feols(sat ~ i(rel, no_incentive, ref = "2023") | athlete_id^season + team_game_no, h8r, cluster = ~athlete_id)

state_reg <- bind_rows(
  tidy_terms(rest_models$state_post,  ".", sample = "full schedule", spec = "state main effects + state x post"),
  tidy_terms(rest_models$gap_post,    ".", sample = "full schedule", spec = "no-incentive + no-incentive x post"),
  tidy_terms(rest_modelsr$state_post, ".", sample = "rows only",     spec = "state main effects + state x post"),
  tidy_terms(rest_modelsr$gap_post,   ".", sample = "rows only",     spec = "no-incentive + no-incentive x post"),
  tidy_terms(rest_modelsr$state_post_noME, ":post", sample = "rows only", spec = "exploratory: state x post, no main effects")
)
cat("\n  State x post regressions, athlete^season + team_game_no FE, clustered by player:\n")
pr(state_reg %>% select(sample, spec, term, est, se, p, mde) %>% r3())

repl_sec <- state_reg %>% filter(spec == "exploratory: state x post, no main effects", str_detect(term, "secured"))
check(abs(repl_sec$est - (-0.028)) < 0.01, "rows-only exploratory spec reproduces secured x post of findings sec. 5")
full_int <- state_reg %>% filter(sample == "full schedule", str_detect(term, ":post"))
check(all(full_int$p > 0.05), "full schedule: no state x post interaction significant at 5%")

gap_by_season <- bind_rows(
  tidy_terms(rest_models$gap_levels,   "^rel::", sample = "full schedule", spec = "gap level"),
  tidy_terms(rest_models$gap_es_2023,  "^rel::", sample = "full schedule", spec = "gap relative to 2023"),
  tidy_terms(rest_modelsr$gap_levels,  "^rel::", sample = "rows only",     spec = "gap level"),
  tidy_terms(rest_modelsr$gap_es_2023, "^rel::", sample = "rows only",     spec = "gap relative to 2023"),
  tidy_terms(rest_modelsr$gap_es_noME, "^rel::", sample = "rows only",     spec = "exploratory: no main effect")
) %>% mutate(season = season_of(term)) %>% arrange(sample, spec, season)
cat("\n  No-incentive gap by season:\n")
pr(gap_by_season %>% select(sample, spec, season, est, se, p, mde) %>% r3())
repl_2024 <- gap_by_season %>% filter(spec == "exploratory: no main effect", season == 2024)
check(abs(repl_2024$est - (-0.038)) < 0.01, "rows-only exploratory spec reproduces the 2024 gap coefficient of findings sec. 5")

write_csv(state_reg, "results/tables/rest_state_regressions.csv")
write_csv(gap_by_season, "results/tables/rest_gap_by_season.csv")


# -----------------------------------------------------------------------------
# 3. STARS VS HIGH-MINUTE NON-STARS
# -----------------------------------------------------------------------------
stage("STAGE 3: stars vs non-stars")

raw_table <- function(d) d %>%
  group_by(season, group) %>%
  summarise(n = n(), n_players = n_distinct(athlete_id), sat = mean(sat), .groups = "drop") %>%
  pivot_wider(names_from = group, values_from = c(n, n_players, sat)) %>%
  mutate(gap = sat_star - `sat_non-star`)
raw_rates  <- raw_table(full)
raw_ratesr <- raw_table(rows)
cat("\n  FULL SCHEDULE: absence rate of healthy late-season players by season and group:\n")
pr(r3(raw_rates))
cat("\n  ROWS-ONLY replication (findings sec. 7: star 2014 .071, 2018 .028, 2023 .011, 2024 .017, 2025 .042, 2026 .014):\n")
pr(r3(raw_ratesr %>% select(season, `sat_non-star`, sat_star, gap)))

fit_stars <- function(d) {
  d17 <- d %>% filter(season <= 2019) %>% mutate(post2017 = as.numeric(season >= 2018))
  d22 <- d %>% filter(season >= 2022)
  list(
    es_2023 = feols(sat ~ i(rel, star, ref = "2023") | athlete_id + season + team_game_no, d, cluster = ~athlete_id),
    es_2017 = feols(sat ~ i(rel, star, ref = "2017") | athlete_id + season + team_game_no, d, cluster = ~athlete_id),
    pooled_post_all = feols(sat ~ post:star | athlete_id + season + team_game_no, d, cluster = ~athlete_id),
    pooled_ppp_2022 = feols(sat ~ post:star | athlete_id + season + team_game_no, d22, cluster = ~athlete_id),
    pooled_2017     = feols(sat ~ post2017:star | athlete_id + season + team_game_no, d17, cluster = ~athlete_id)
  )
}
star_models  <- fit_stars(full)
star_modelsr <- fit_stars(rows)

es_table <- function(ms, sample) bind_rows(
  tidy_terms(ms$es_2023, "^rel::", sample = sample, ref = 2023),
  tidy_terms(ms$es_2017, "^rel::", sample = sample, ref = 2017)
) %>% mutate(season = season_of(term)) %>%
  bind_rows(tibble(sample = sample, ref = c(2023, 2017), season = c(2023, 2017), est = 0, se = 0, lo = 0, hi = 0, mde = 0)) %>%
  arrange(ref, season)
pooled_table <- function(ms, sample) bind_rows(
  tidy_terms(ms$pooled_post_all, ":star", sample = sample, window = "2014-2026: post-rule (2024-26) x star"),
  tidy_terms(ms$pooled_ppp_2022, ":star", sample = sample, window = "2022-2026: post-rule (2024-26) x star"),
  tidy_terms(ms$pooled_2017,     ":star", sample = sample, window = "2014-2019: post-2017-policy (2018-19) x star")
) %>% mutate(n = c(nobs(ms$pooled_post_all), nobs(ms$pooled_ppp_2022), nobs(ms$pooled_2017)))

es_rest     <- bind_rows(es_table(star_models, "full schedule"), es_table(star_modelsr, "rows only"))
pooled_rest <- bind_rows(pooled_table(star_models, "full schedule"), pooled_table(star_modelsr, "rows only"))

cat("\n  Star x season event studies (star minus non-star, relative to the reference season):\n")
pr(es_rest %>% select(sample, ref, season, est, se, p, mde) %>% r3())
cat("\n  Pooled star-specific changes with MDEs:\n")
pr(pooled_rest %>% select(sample, window, n, est, se, p, mde) %>% r3())

es26r <- es_rest %>% filter(sample == "rows only", ref == 2023, season == 2026)
check(abs(es26r$est - (-0.021)) < 0.01, "rows-only replication reproduces the 2026 coefficient of findings sec. 7")
es_full_post <- es_rest %>% filter(sample == "full schedule", season %in% POST_SEASONS)
check(all(es_full_post$p > 0.05), "full schedule: no post-rule star x season coefficient significant at 5%")
check(all(pooled_rest$mde[pooled_rest$sample == "full schedule"] < 0.06), "full-schedule pooled MDEs below 6 percentage points")

write_csv(raw_rates, "results/tables/rest_raw_by_season.csv")
write_csv(raw_ratesr, "results/tables/rest_raw_by_season_rowsonly.csv")
write_csv(es_rest, "results/tables/rest_es_stars_vs_nonstars.csv")
write_csv(pooled_rest, "results/tables/rest_pooled_did.csv")


# -----------------------------------------------------------------------------
# 4. WHAT THE DNP ROWS SAY, WHERE THEY EXIST
# -----------------------------------------------------------------------------
stage("STAGE 4: DNP reasons among healthy late-season star absences")

classify_reason <- function(r) {
  r <- str_to_lower(coalesce(r, ""))
  case_when(str_detect(r, "rest|load|maintenance|management")                         ~ "rest",
            str_detect(r, "coach")                                                    ~ "coach's decision",
            str_detect(r, "personal|suspen|trade|not with|league|conditioning|health and safety|protocol|bereav|family|birth") ~ "other",
            TRUE                                                                      ~ "injury or illness")
}
reasons <- h8 %>% filter(sat == 1) %>%
  mutate(class = if_else(has_row, classify_reason(reason), "no row (reason unknown)"),
         period = if_else(post_rule, "post", "pre")) %>%
  count(period, class) %>% group_by(period) %>% mutate(share = n / sum(n)) %>% ungroup() %>%
  arrange(period, desc(n))
cat("\n  Composition of healthy late-season star absences:\n")
pr(r3(reasons))
rest_share <- reasons %>% group_by(period) %>%
  summarise(absences = sum(n), with_row = sum(n[class != "no row (reason unknown)"]),
            rest_or_coach = sum(n[class %in% c("rest", "coach's decision")]),
            share_rest_or_coach_lower_bound = rest_or_coach / absences, .groups = "drop")
cat("  Absences coded rest or coach's decision, as a share of all absences (a lower bound on discretionary rest):\n")
pr(r3(rest_share))
write_csv(reasons, "results/tables/rest_absence_reasons.csv")
write_csv(rest_share, "results/tables/rest_absence_reason_bounds.csv")


# -----------------------------------------------------------------------------
# 5. NATIONAL TV (footnote; broadcast strings empty before 2022)
# -----------------------------------------------------------------------------
stage("STAGE 5: national TV footnote")

tv_share <- panel %>% distinct(season, game_id, national_tv) %>% group_by(season) %>%
  summarise(share_national = mean(national_tv), .groups = "drop")
h8_tv <- h8 %>% filter(season >= 2022) %>% mutate(tv = as.numeric(national_tv))
tv_rates <- h8_tv %>% group_by(post_rule, national_tv) %>% summarise(n = n(), sat = mean(sat), .groups = "drop") %>%
  pivot_wider(names_from = post_rule, values_from = c(n, sat)) %>%
  rename_with(~ str_replace(.x, "FALSE", "pre") %>% str_replace("TRUE", "post"))
tv_model <- feols(sat ~ post:tv + tv | athlete_id^season + team_game_no, h8_tv, cluster = ~athlete_id)
tv_dd <- tidy_terms(tv_model, "post:tv")
cat("\n  Share of games flagged national TV (zero before 2022):\n"); pr(r3(tv_share))
cat("  Absence by TV status, 2022-23 vs 2024-26, full schedule; triple difference:\n")
pr(r3(tv_rates)); pr(r3(tv_dd))
check(tv_dd$p > 0.05, "TV triple difference not significant (findings sec. 6)")
write_csv(tv_rates, "results/tables/rest_tv_rates.csv")
write_csv(tv_dd, "results/tables/rest_tv_ddd.csv")


# -----------------------------------------------------------------------------
# 6. SAVE OBJECTS AND FIGURES
# -----------------------------------------------------------------------------
stage("STAGE 6: save")

write_rds(list(full = c(rest_models, star_models, list(tv = tv_model)), rows_only = c(rest_modelsr, star_modelsr)),
          "data/derived/rest_models.rds")
write_rds(list(state_post = state_post, state_post_rowsonly = state_postr, state_season = state_season, state_reg = state_reg,
               gap_by_season = gap_by_season, raw_rates = raw_rates, raw_rates_rowsonly = raw_ratesr, es_rest = es_rest,
               pooled_rest = pooled_rest, reasons = reasons, rest_share = rest_share, tv_rates = tv_rates, tv_dd = tv_dd),
          "data/derived/rest_tables.rds")

p_state <- state_season %>%
  select(season, starts_with("sat_"), starts_with("n_")) %>%
  pivot_longer(-season, names_to = c(".value", "state"), names_pattern = "(sat|n)_(.*)") %>%
  mutate(state = factor(state, levels = c("reachable", "secured", "unreachable"))) %>%
  ggplot(aes(x = season, y = sat, colour = state, shape = state)) +
  annotate("rect", xmin = 2023.5, xmax = 2026.5, ymin = -Inf, ymax = Inf, alpha = 0.08, fill = "firebrick") +
  geom_line() + geom_point(aes(size = n)) +
  scale_colour_manual(values = c(reachable = "grey20", secured = "steelblue4", unreachable = "darkorange3")) +
  scale_size_area(max_size = 5, guide = "none") +
  scale_x_continuous(breaks = EST_SEASONS) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(x = "Season (end year)", y = "Share absent after playing the previous game", colour = "Eligibility state", shape = "Eligibility state",
       title = "Late-season absences of stars who played the previous game, by 65-game eligibility state",
       subtitle = "Games 56 onward; full team schedule; point size = player-games in the cell") +
  theme_minimal(base_size = 12) + theme(panel.grid.minor = element_blank(), legend.position = "bottom")
ggsave("results/figures/rest_by_state.png", p_state, width = 8, height = 5.5, dpi = 200)
write_rds(p_state, "results/figures/rest_by_state.rds")

p_state_bar <- state_post %>%
  select(state, sat_pre, sat_post, se_pre, se_post) %>%
  pivot_longer(-state, names_to = c(".value", "period"), names_pattern = "(sat|se)_(.*)") %>%
  mutate(period = factor(period, levels = c("pre", "post"), labels = c("Pre-rule (2014-2019, 2022-2023)", "Post-rule (2024-2026)"))) %>%
  ggplot(aes(x = state, y = sat, fill = period)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.65) +
  geom_errorbar(aes(ymin = sat - 1.96 * se, ymax = sat + 1.96 * se), position = position_dodge(width = 0.7), width = 0.2) +
  scale_fill_manual(values = c("grey60", "firebrick")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), expand = expansion(mult = c(0, 0.05))) +
  labs(x = "65-game eligibility state entering the game", y = "Share absent after playing the previous game", fill = NULL,
       title = "Late-season absence of stars who played the previous game, by eligibility state",
       subtitle = "Games 56 onward, full team schedule; bars with 95% binomial confidence intervals") +
  theme_minimal(base_size = 12) + theme(panel.grid.minor = element_blank(), legend.position = "bottom")
ggsave("results/figures/rest_by_state_bars.png", p_state_bar, width = 7, height = 5, dpi = 200)
write_rds(p_state_bar, "results/figures/rest_by_state_bars.rds")

p_raw <- raw_rates %>%
  select(season, starts_with("sat_")) %>%
  pivot_longer(-season, names_to = "group", values_to = "sat", names_prefix = "sat_") %>%
  ggplot(aes(x = season, y = sat, colour = group, shape = group)) +
  annotate("rect", xmin = 2017.5, xmax = 2018.5, ymin = -Inf, ymax = Inf, alpha = 0.08, fill = "grey40") +
  annotate("rect", xmin = 2023.5, xmax = 2026.5, ymin = -Inf, ymax = Inf, alpha = 0.08, fill = "firebrick") +
  geom_line() + geom_point(size = 2.2) +
  scale_colour_manual(values = c(star = "firebrick", `non-star` = "grey30")) +
  scale_x_continuous(breaks = EST_SEASONS) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(x = NULL, y = "Share absent", colour = NULL, shape = NULL,
       title = "Late-season absences after playing the previous game: stars vs high-minute non-stars",
       subtitle = "Grey band: first season of the 2017 resting policy. Red band: 65-game rule and PPP") +
  theme_minimal(base_size = 12) + theme(panel.grid.minor = element_blank(), legend.position = "bottom")
p_es_rest <- es_rest %>% filter(sample == "full schedule", ref == 2023) %>%
  ggplot(aes(x = season, y = est)) +
  annotate("rect", xmin = 2023.5, xmax = 2026.5, ymin = -Inf, ymax = Inf, alpha = 0.08, fill = "firebrick") +
  geom_hline(yintercept = 0, colour = "grey50") +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.25, colour = "grey30") +
  geom_point(size = 2.2) +
  scale_x_continuous(breaks = EST_SEASONS) +
  labs(x = "Season (end year)", y = "Star minus non-star, relative to 2023",
       subtitle = "Event study: player, season and game-number fixed effects; 95% CIs clustered by player") +
  theme_minimal(base_size = 12) + theme(panel.grid.minor = element_blank())
p_stars <- if (requireNamespace("patchwork", quietly = TRUE)) patchwork::wrap_plots(p_raw, p_es_rest, ncol = 1) else p_es_rest
ggsave("results/figures/rest_stars_vs_nonstars.png", p_stars, width = 8, height = 8, dpi = 200)
write_rds(list(raw = p_raw, es = p_es_rest), "results/figures/rest_stars_vs_nonstars.rds")
cat("  saved rest_*.csv, rest_models.rds, rest_tables.rds, rest_by_state.png, rest_stars_vs_nonstars.png\n")

cat("\nDone.\n")
