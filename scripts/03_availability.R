# =============================================================================
# 03_availability.R
#
# NBA 65-game rule: availability results
#
#   1. Games-played and qualifying-games DiD event studies, stars vs
#      high-minute non-stars (ref 2023), with all non-stars as a robustness
#      control; pooled post x star DiDs; MDEs at 80% power.
#   2. Bunching at 65 qualifying games: excess-mass estimator with the pre-rule
#      star distribution as the counterfactual, bootstrap SEs and CIs.
#   3. At-risk reach rates (from at_risk.rds built in 02): pooled tests with
#      MDEs, and the maximal-effect bound on star mean games.
#
# Inputs:  data/derived/player_season_clean.rds, data/derived/at_risk.rds
# Outputs: data/derived/availability_models.rds, es_availability.rds,
#          bunching.rds, at_risk_bound.rds; results/tables/*.csv; results/figures/*
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
set.seed(20260915)

SEASONS        <- 2014:2026
COVID_SEASONS  <- c(2020, 2021)
POST_SEASONS   <- 2024:2026
EST_SEASONS    <- setdiff(SEASONS, COVID_SEASONS)
RULE_GAMES     <- 65
MDE_K          <- qnorm(0.975) + qnorm(0.80)     # 2.80: MDE at 80% power, 5% two-sided
N_BOOT         <- 2000

stage <- function(txt) cat("\n", strrep("=", 78), "\n", txt, "\n", strrep("=", 78), "\n", sep = "")
check <- function(cond, msg) {
  if (!isTRUE(cond)) stop("CHECK FAILED: ", msg, call. = FALSE)
  cat("  ok:", msg, "\n")
}
pr <- function(x, ...) print(x, n = Inf, width = Inf, ...)

# Tidy the season x treatment coefficients of an i(rel, treat, ref = ...) model
tidy_es <- function(m, ref, outcome, sample) {
  as_tibble(coeftable(m), rownames = "term") %>%
    filter(str_detect(term, "^rel::")) %>%
    transmute(outcome, sample, ref, season = as.integer(str_extract(term, "(?<=::)\\d{4}")),
              est = Estimate, se = `Std. Error`, p = `Pr(>|t|)`,
              lo = est - qnorm(0.975) * se, hi = est + qnorm(0.975) * se, mde = MDE_K * se) %>%
    bind_rows(tibble(outcome, sample, ref, season = ref, est = 0, se = 0, p = NA, lo = 0, hi = 0, mde = 0)) %>%
    arrange(season)
}
tidy_pooled <- function(m, term, outcome, sample, label) {
  ct <- as_tibble(coeftable(m), rownames = "t") %>% filter(t == term)
  tibble(outcome, sample, label, est = ct$Estimate, se = ct$`Std. Error`, p = ct$`Pr(>|t|)`,
         lo = est - qnorm(0.975) * se, hi = est + qnorm(0.975) * se, mde = MDE_K * se,
         n = nobs(m), n_clusters = length(unique(m$fixef_id$athlete_id)))
}

ps      <- read_rds("data/derived/player_season_clean.rds")
at_risk <- read_rds("data/derived/at_risk.rds")
check(all(c("games_played", "qualifying_games", "star_ppp", "high_minute_nonstar", "hm_lag", "rot_lag", "games_rostered") %in% names(ps)),
      "player_season_clean has required columns")


# -----------------------------------------------------------------------------
# 1. DiD EVENT STUDIES: games played and qualifying games
# -----------------------------------------------------------------------------
stage("STAGE 1: availability event studies")

# Control groups are defined on the PRIOR season (hm_lag, rot_lag from 02) so that membership is
# fixed before the outcome is realised. The exploratory design used a contemporaneous control
# (mpg >= 28 and games_played >= 40 in season s) together with a games_rostered >= 40 filter; the
# filter binds only on stars and removes their long-injury seasons. That design is kept as a
# comparison ("contemporaneous") and checked against the findings doc, but is not the paper's estimate.
did_df <- ps %>%
  filter(!covid) %>%
  mutate(rel  = factor(season, levels = EST_SEASONS),
         star = as.numeric(star_ppp),
         post = as.numeric(post_rule))
d_hm   <- did_df %>% filter(season >= 2015, star_ppp | hm_lag)                          # primary: lagged high-minute non-stars
d_rot  <- did_df %>% filter(season >= 2015, star_ppp | rot_lag)                         # robustness: lagged rotation players
d_cur  <- did_df %>% filter(star_ppp | high_minute_nonstar, games_rostered >= 40)       # exploratory: contemporaneous + filter
d_all  <- did_df %>% filter(games_rostered >= 40)                                       # reference only: all non-stars

cat("  sample sizes: primary", nrow(d_hm), "player-seasons (", sum(d_hm$star), "star );",
    "rotation control", nrow(d_rot), "; contemporaneous", nrow(d_cur), "; all-non-star", nrow(d_all), "\n")

models <- list(
  gp_hm    = feols(games_played     ~ i(rel, star, ref = "2023") | athlete_id + season, d_hm,  cluster = ~athlete_id),
  qg_hm    = feols(qualifying_games ~ i(rel, star, ref = "2023") | athlete_id + season, d_hm,  cluster = ~athlete_id),
  gp_rot   = feols(games_played     ~ i(rel, star, ref = "2023") | athlete_id + season, d_rot, cluster = ~athlete_id),
  qg_rot   = feols(qualifying_games ~ i(rel, star, ref = "2023") | athlete_id + season, d_rot, cluster = ~athlete_id),
  gp_cur   = feols(games_played     ~ i(rel, star, ref = "2023") | athlete_id + season, d_cur, cluster = ~athlete_id),
  qg_cur   = feols(qualifying_games ~ i(rel, star, ref = "2023") | athlete_id + season, d_cur, cluster = ~athlete_id),
  gp_all   = feols(games_played     ~ i(rel, star, ref = "2023") | athlete_id + season, d_all, cluster = ~athlete_id),
  gp_hm_p  = feols(games_played     ~ post:star | athlete_id + season, d_hm,  cluster = ~athlete_id),
  qg_hm_p  = feols(qualifying_games ~ post:star | athlete_id + season, d_hm,  cluster = ~athlete_id),
  gp_rot_p = feols(games_played     ~ post:star | athlete_id + season, d_rot, cluster = ~athlete_id),
  qg_rot_p = feols(qualifying_games ~ post:star | athlete_id + season, d_rot, cluster = ~athlete_id),
  gp_cur_p = feols(games_played     ~ post:star | athlete_id + season, d_cur, cluster = ~athlete_id),
  qg_cur_p = feols(qualifying_games ~ post:star | athlete_id + season, d_cur, cluster = ~athlete_id),
  ge65_hm_p = feols(as.numeric(qualifying_games >= RULE_GAMES) ~ post:star | athlete_id + season, d_hm, cluster = ~athlete_id)
)

es_availability <- bind_rows(
  tidy_es(models$gp_hm,  2023, "games_played",     "high_minute_nonstar"),
  tidy_es(models$qg_hm,  2023, "qualifying_games", "high_minute_nonstar"),
  tidy_es(models$gp_rot, 2023, "games_played",     "rotation_nonstar"),
  tidy_es(models$qg_rot, 2023, "qualifying_games", "rotation_nonstar"),
  tidy_es(models$gp_cur, 2023, "games_played",     "contemporaneous"),
  tidy_es(models$qg_cur, 2023, "qualifying_games", "contemporaneous"),
  tidy_es(models$gp_all, 2023, "games_played",     "all_nonstar")
)

pooled_availability <- bind_rows(
  tidy_pooled(models$gp_hm_p,   "post:star", "games_played",     "high_minute_nonstar", "post x star"),
  tidy_pooled(models$qg_hm_p,   "post:star", "qualifying_games", "high_minute_nonstar", "post x star"),
  tidy_pooled(models$gp_rot_p,  "post:star", "games_played",     "rotation_nonstar",    "post x star"),
  tidy_pooled(models$qg_rot_p,  "post:star", "qualifying_games", "rotation_nonstar",    "post x star"),
  tidy_pooled(models$gp_cur_p,  "post:star", "games_played",     "contemporaneous",     "post x star"),
  tidy_pooled(models$qg_cur_p,  "post:star", "qualifying_games", "contemporaneous",     "post x star"),
  tidy_pooled(models$ge65_hm_p, "post:star", "share_ge65",       "high_minute_nonstar", "post x star")
)

show <- function(o, smp) es_availability %>% filter(outcome == o, sample == smp) %>%
  mutate(across(c(est, se, lo, hi, mde), ~ round(.x, 2)), p = round(p, 3)) %>% select(season, est, se, p, lo, hi, mde)
cat("\n  PRIMARY: games played, stars vs lagged high-minute non-stars, ref 2023 (no outcome filter):\n"); pr(show("games_played", "high_minute_nonstar"))
cat("\n  PRIMARY: qualifying games:\n"); pr(show("qualifying_games", "high_minute_nonstar"))
cat("\n  Rotation control (lagged), games played:\n"); pr(show("games_played", "rotation_nonstar"))
cat("\n  Rotation control (lagged), qualifying games:\n"); pr(show("qualifying_games", "rotation_nonstar"))
cat("\n  Exploratory design (contemporaneous control + rostered >= 40), games played",
    "(findings sec. 3: 2024 1.12 (2.07), 2025 -0.47 (2.35), 2026 2.07 (2.65)):\n"); pr(show("games_played", "contemporaneous"))
cat("\n  All-non-star control (pre-trends fail; reference only):\n"); pr(show("games_played", "all_nonstar"))
cat("\n  Pooled post x star DiDs with MDEs:\n")
pr(pooled_availability %>% mutate(across(c(est, se, lo, hi, mde), ~ round(.x, 3)), p = round(p, 3)))

ref_gp <- tibble(season = c(2024, 2025, 2026), ref_est = c(1.12, -0.47, 2.07))
cmp <- es_availability %>% filter(outcome == "games_played", sample == "contemporaneous") %>% inner_join(ref_gp, by = "season")
check(all(abs(cmp$est - cmp$ref_est) < 1), "exploratory design reproduces findings sec. 3 within 1 game")
es_used <- es_availability %>% filter(sample == "high_minute_nonstar")
check(all(es_used$p[es_used$season %in% POST_SEASONS] > 0.05, na.rm = TRUE),
      "primary control: no post-rule event-study coefficient significant at 5%")
check(all(es_used$p[es_used$season < 2023] > 0.05, na.rm = TRUE),
      "primary control: no pre-period coefficient significant at 5%")
es_rot <- es_availability %>% filter(sample == "rotation_nonstar")
cat("  rotation control: coefficients with p < 0.05:", sum(es_rot$p < 0.05, na.rm = TRUE), "of", sum(!is.na(es_rot$p)),
    "(", paste(paste0(es_rot$outcome[which(es_rot$p < 0.05)], " ", es_rot$season[which(es_rot$p < 0.05)]), collapse = "; "), ")\n")
check(all(pooled_availability$mde[pooled_availability$outcome != "share_ge65" & pooled_availability$sample %in% c("high_minute_nonstar", "rotation_nonstar")] < 8),
      "pooled MDEs below 8 games")

# Fixed-cohort DiDs for every adjacent pair of seasons: groups fixed at their status in the first
# season, players present in both. Puts the 2023 -> 2024 change against the distribution of
# year-to-year swings before the rule.
pairs <- list(c(2015, 2016), c(2016, 2017), c(2017, 2018), c(2018, 2019), c(2022, 2023), c(2023, 2024), c(2024, 2025), c(2025, 2026))
cohort_pairs <- map_dfr(pairs, function(pr_) {
  g  <- did_df %>% filter(season == pr_[1]) %>% transmute(athlete_id, grp = case_when(star_ppp ~ "star", hm_lag ~ "ctrl", TRUE ~ NA_character_)) %>% filter(!is.na(grp))
  tw <- did_df %>% filter(season %in% pr_) %>% inner_join(g, by = "athlete_id") %>% group_by(athlete_id) %>% filter(n() == 2) %>% ungroup() %>%
    mutate(s = as.numeric(grp == "star"), later = as.numeric(season == pr_[2]))
  m  <- feols(games_played ~ later:s | athlete_id + season, tw, cluster = ~athlete_id)
  ct <- coeftable(m)
  tibble(pair = paste(pr_, collapse = "->"), n_star = sum(tw$s == 1) / 2, n_ctrl = sum(tw$s == 0) / 2,
         star_first = mean(tw$games_played[tw$s == 1 & tw$later == 0]), star_second = mean(tw$games_played[tw$s == 1 & tw$later == 1]),
         ctrl_first = mean(tw$games_played[tw$s == 0 & tw$later == 0]), ctrl_second = mean(tw$games_played[tw$s == 0 & tw$later == 1]),
         est = ct[1, 1], se = ct[1, 2], p = ct[1, 4], mde = MDE_K * ct[1, 2])
})
cat("\n  Fixed-cohort adjacent-season DiDs (games played), lagged control:\n")
pr(cohort_pairs %>% mutate(across(where(is.double), ~ round(.x, 2))))
write_csv(cohort_pairs, "results/tables/did_cohort_pairs.csv")

# Why the rotation control differs for qualifying games: a 20-minute-per-game player's qualifying
# count depends on the 20-minute cutoff game by game. Ratio of qualifying games to games played by group.
qg_ratio <- did_df %>% filter(season >= 2015) %>%
  mutate(grp = case_when(star_ppp ~ "star", hm_lag ~ "hm_lag", rot_lag ~ "rot_lag", TRUE ~ NA_character_)) %>% filter(!is.na(grp), games_played > 0) %>%
  group_by(season, grp) %>% summarise(n = n(), gp = mean(games_played), qg = mean(qualifying_games), ratio = mean(qualifying_games / games_played), .groups = "drop") %>%
  pivot_wider(names_from = grp, values_from = c(n, gp, qg, ratio))
cat("\n  Qualifying games / games played by group and season (rotation control sits on the 20-minute margin):\n")
pr(qg_ratio %>% mutate(across(where(is.double), ~ round(.x, 2))))
write_csv(qg_ratio, "results/tables/qg_gp_ratio_by_group.csv")

# Composition: the raw 2023 -> 2024 change in star mean games played versus the within-player change.
# Stayers are players who are stars in both seasons; entrants are 2024 stars who were not 2023 stars;
# leavers are 2023 stars who are not 2024 stars.
comp <- function(d, y) {
  s23 <- d %>% filter(season == 2023, star_ppp) %>% select(athlete_id, y23 = all_of(y))
  s24 <- d %>% filter(season == 2024, star_ppp) %>% select(athlete_id, y24 = all_of(y))
  both <- inner_join(s23, s24, by = "athlete_id")
  tibble(outcome = y,
         mean_2023 = mean(s23$y23), mean_2024 = mean(s24$y24), raw_change = mean_2024 - mean_2023,
         n_2023 = nrow(s23), n_2024 = nrow(s24), n_stayers = nrow(both),
         stayers_2023 = mean(both$y23), stayers_2024 = mean(both$y24), stayers_change = stayers_2024 - stayers_2023,
         entrants_2024 = mean(s24$y24[!s24$athlete_id %in% both$athlete_id]), n_entrants = sum(!s24$athlete_id %in% both$athlete_id),
         leavers_2023 = mean(s23$y23[!s23$athlete_id %in% both$athlete_id]), n_leavers = sum(!s23$athlete_id %in% both$athlete_id))
}
composition <- bind_rows(comp(ps %>% filter(!covid), "games_played"), comp(ps %>% filter(!covid), "qualifying_games"),
                         comp(ps %>% filter(!covid) %>% mutate(star_ppp = hm_lag), "games_played") %>% mutate(outcome = "games_played_control"))
cat("\n  Composition of the 2023 -> 2024 change (stars; last row = lagged high-minute non-stars):\n")
pr(composition %>% mutate(across(where(is.double), ~ round(.x, 1))))
write_csv(composition, "results/tables/composition_2024.csv")

write_rds(models, "data/derived/availability_models.rds")
write_rds(es_availability, "data/derived/es_availability.rds")
write_csv(es_availability, "results/tables/es_availability.csv")
write_csv(pooled_availability, "results/tables/did_availability_pooled.csv")

# Figure: event-study coefficients, two outcomes, primary control
band <- pooled_availability %>% filter(sample == "high_minute_nonstar", outcome %in% c("games_played", "qualifying_games")) %>%
  mutate(outcome = recode(outcome, games_played = "Games played", qualifying_games = "Qualifying games"))
p_es <- es_availability %>%
  filter(sample == "high_minute_nonstar") %>%
  mutate(outcome = recode(outcome, games_played = "Games played", qualifying_games = "Qualifying games"),
         period = case_when(season %in% POST_SEASONS ~ "Post-rule", TRUE ~ "Pre-rule")) %>%
  ggplot(aes(x = season, y = est)) +
  annotate("rect", xmin = 2023.5, xmax = 2026.5, ymin = -Inf, ymax = Inf, alpha = 0.08, fill = "firebrick") +
  geom_rect(data = band, aes(xmin = 2023.5, xmax = 2026.5, ymin = lo, ymax = hi), inherit.aes = FALSE, fill = "steelblue", alpha = 0.25) +
  geom_segment(data = band, aes(x = 2023.5, xend = 2026.5, y = est, yend = est), inherit.aes = FALSE, colour = "steelblue4", linewidth = 0.8) +
  geom_hline(yintercept = 0, colour = "grey50") +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.25, colour = "grey30") +
  geom_point(aes(shape = period), size = 2.4, fill = "white") +
  scale_shape_manual(values = c("Pre-rule" = 19, "Post-rule" = 21), guide = "none") +
  scale_x_continuous(breaks = EST_SEASONS) +
  facet_wrap(~ outcome, ncol = 1) +
  labs(x = "Season (end year); 2020 and 2021 excluded", y = "Star minus high-minute non-star, relative to 2023 (games)",
       title = "Availability of stars relative to high-minute non-stars (prior-season status)",
       subtitle = "Player and season fixed effects; 95% CIs clustered by player. Blue band: pooled post x star estimate with 95% CI") +
  theme_minimal(base_size = 12) + theme(panel.grid.minor = element_blank())
ggsave("results/figures/es_availability.png", p_es, width = 8, height = 7, dpi = 200)
write_rds(p_es, "results/figures/es_availability.rds")
cat("  saved es_availability.csv, did_availability_pooled.csv, es_availability.png\n")


# -----------------------------------------------------------------------------
# 2. BUNCHING: excess mass at 65 with the pre-rule distribution as counterfactual
# -----------------------------------------------------------------------------
stage("STAGE 2: bunching estimator")

bunch_df <- ps %>% filter(star_ppp, !covid) %>% select(season, athlete_id, q = qualifying_games, post_rule)
q_grid   <- 0:82
check(all(bunch_df$q %in% q_grid), "qualifying games within 0-82")

# Excess mass in bins B relative to a counterfactual built from the pre-rule pmf.
#   B_hat  = sum_{q in B} [ obs_post(q) - N_post * f_pre(q) ]         (player-seasons)
#   b      = B_hat / mean_{q in B} [ N_post * f_pre(q) ]               (Chetty et al. normalisation:
#                                                                       excess in units of counterfactual bin mass)
#   share  = B_hat / N_post                                            (share of post-rule star-seasons)
#   ratio  = obs / counterfactual in B
# Missing mass M below the threshold is reported the same way.
excess_mass <- function(q_pre, q_post, bins_B, bins_M) {
  n_post <- length(q_post)
  f_pre  <- tabulate(q_pre + 1L, nbins = 83) / length(q_pre)
  obs    <- tabulate(q_post + 1L, nbins = 83)
  cf     <- n_post * f_pre
  B_hat  <- sum(obs[bins_B + 1L] - cf[bins_B + 1L])
  M_hat  <- sum(obs[bins_M + 1L] - cf[bins_M + 1L])
  c(B_hat = B_hat, b = B_hat / mean(cf[bins_B + 1L]), share_B = B_hat / n_post,
    ratio_B = sum(obs[bins_B + 1L]) / sum(cf[bins_B + 1L]),
    M_hat = M_hat, m = M_hat / mean(cf[bins_M + 1L]), share_M = M_hat / n_post,
    ratio_M = sum(obs[bins_M + 1L]) / sum(cf[bins_M + 1L]),
    obs_B = sum(obs[bins_B + 1L]), cf_B = sum(cf[bins_B + 1L]), obs_M = sum(obs[bins_M + 1L]), cf_M = sum(cf[bins_M + 1L]))
}

windows <- tribble(
  ~window,             ~bins_B,  ~bins_M,
  "65 vs 64",          65L,      64L,
  "65-66 vs 63-64",    65:66,    63:64,
  "65-68 vs 58-64",    65:68,    58:64
)
counterfactuals <- list(all_pre = setdiff(EST_SEASONS, POST_SEASONS), recent_pre = c(2022, 2023))

bunching <- map_dfr(names(counterfactuals), function(cfname) {
  q_pre  <- bunch_df %>% filter(season %in% counterfactuals[[cfname]]) %>% pull(q)
  q_post <- bunch_df %>% filter(post_rule) %>% pull(q)
  map_dfr(seq_len(nrow(windows)), function(w) {
    est  <- excess_mass(q_pre, q_post, windows$bins_B[[w]], windows$bins_M[[w]])
    boot <- replicate(N_BOOT, excess_mass(sample(q_pre, replace = TRUE), sample(q_post, replace = TRUE),
                                          windows$bins_B[[w]], windows$bins_M[[w]]))
    boot[!is.finite(boot)] <- NA          # a resample with zero counterfactual mass in a one-game bin
    tibble(counterfactual = cfname, window = windows$window[w], n_pre = length(q_pre), n_post = length(q_post),
           stat = names(est), est = unname(est),
           se = apply(boot, 1, sd, na.rm = TRUE), lo = apply(boot, 1, quantile, 0.025, na.rm = TRUE),
           hi = apply(boot, 1, quantile, 0.975, na.rm = TRUE), boot_dropped = rowSums(is.na(boot)))
  })
})

cat("\n  Excess mass at and above 65 (b) and missing mass below (m), post-rule stars vs pre-rule counterfactual:\n")
pr(bunching %>% filter(stat %in% c("b", "m", "share_B", "share_M", "obs_B", "cf_B", "obs_M", "cf_M")) %>%
     mutate(across(c(est, se, lo, hi), ~ round(.x, 3))))

b_main <- bunching %>% filter(counterfactual == "all_pre", stat == "b")
check(all(b_main$lo < 0 & b_main$hi > 0), "no bunching window rejects zero excess mass (findings sec. 1)")

# Bin-share table (findings sec. 1 layout) on clean counts
bin_tab <- bunch_df %>%
  mutate(bin = case_when(q %in% 58:64 ~ "58-64 (below)", q %in% 65:68 ~ "65-68 (just above)", q >= 69 ~ "69+", TRUE ~ "<58"),
         bin = factor(bin, levels = c("<58", "58-64 (below)", "65-68 (just above)", "69+")),
         period = if_else(post_rule, "post", "pre")) %>%
  count(period, bin) %>% group_by(period) %>% mutate(share = n / sum(n)) %>% ungroup() %>%
  pivot_wider(names_from = period, values_from = c(n, share)) %>% select(bin, n_pre, n_post, share_pre, share_post)
cat("\n  Mass around the threshold (findings: shares pre .291/.116/.113/.480, post .318/.114/.106/.462):\n")
pr(bin_tab %>% mutate(across(starts_with("share"), ~ round(.x, 3))))

# One-game histogram counts for the figure and the paper's text
hist_tab <- bunch_df %>% mutate(period = if_else(post_rule, "post", "pre")) %>%
  count(period, q) %>% complete(period, q = q_grid, fill = list(n = 0)) %>%
  group_by(period) %>% mutate(share = n / sum(n)) %>% ungroup()
cf_tab <- hist_tab %>% filter(period == "pre") %>% transmute(q, cf_post = share * sum(bunch_df$post_rule))

write_rds(list(estimates = bunching, bins = bin_tab, hist = hist_tab, counterfactual = cf_tab, windows = windows),
          "data/derived/bunching.rds")
write_csv(bunching, "results/tables/bunching_estimates.csv")
write_csv(bin_tab, "results/tables/bunching_bins.csv")
write_csv(hist_tab, "results/tables/bunching_histogram.csv")

p_bunch <- hist_tab %>%
  mutate(period = factor(period, levels = c("pre", "post"),
                         labels = c("Pre-rule: 2014-2019, 2022-2023", "Post-rule: 2024-2026"))) %>%
  ggplot(aes(x = q, y = share)) +
  geom_col(fill = "grey45", width = 1) +
  geom_step(data = hist_tab %>% filter(period == "pre") %>%
              mutate(period = factor("Post-rule: 2024-2026", levels = c("Pre-rule: 2014-2019, 2022-2023", "Post-rule: 2024-2026"))),
            aes(x = q - 0.5, y = share), colour = "firebrick", linewidth = 0.5) +
  geom_vline(xintercept = RULE_GAMES - 0.5, linetype = "dashed") +
  facet_wrap(~ period, ncol = 1) +
  scale_x_continuous(breaks = seq(0, 82, 10), limits = c(-0.5, 82.5)) +
  labs(x = "Qualifying games (>= 20 minutes, plus up to two games of 15-19 minutes)", y = "Share of star player-seasons",
       title = "Qualifying games of stars, before and after the 65-game rule",
       subtitle = "Dashed line: 65-game threshold. Red step in the lower panel: pre-rule distribution (the counterfactual)") +
  theme_minimal(base_size = 12) + theme(panel.grid.minor = element_blank())
ggsave("results/figures/bunching_histogram.png", p_bunch, width = 8, height = 7, dpi = 200)
write_rds(p_bunch, "results/figures/bunching_histogram.rds")
cat("  saved bunching_estimates.csv, bunching_bins.csv, bunching_histogram.png\n")


# -----------------------------------------------------------------------------
# 3. AT-RISK REACH RATES: pooled tests and the maximal-effect bound
# -----------------------------------------------------------------------------
stage("STAGE 3: at-risk reach rates and the bound")

ar <- at_risk %>% mutate(post = as.numeric(post_rule), slack_bin = factor(slack_bin))
ar_risk    <- ar %>% filter(at_risk)
ar_healthy <- ar_risk %>% filter(healthy_at_62)

# Pooled linear probability models of reaching 65 among at-risk star-seasons
reach_models <- list(
  all      = feols(reached ~ post + slack_bin, ar_risk, cluster = ~athlete_id),
  healthy  = feols(reached ~ post + slack_bin, ar_healthy, cluster = ~athlete_id),
  healthy_contender = feols(reached ~ post + slack_bin + contender_cur, ar_healthy, cluster = ~athlete_id),
  tight_healthy = feols(reached ~ post, ar_healthy %>% filter(slack_at_62 <= 5), cluster = ~athlete_id)
)
reach_data <- list(all = ar_risk, healthy = ar_healthy, healthy_contender = ar_healthy,
                   tight_healthy = ar_healthy %>% filter(slack_at_62 <= 5))
reach_tab <- imap_dfr(reach_models, function(m, nm) {
  ct <- as_tibble(coeftable(m), rownames = "t") %>% filter(t == "post")
  tibble(sample = nm, n = nobs(m), n_post = sum(reach_data[[nm]]$post),
         reached_pre = mean(reach_data[[nm]]$reached[reach_data[[nm]]$post == 0]),
         reached_post = mean(reach_data[[nm]]$reached[reach_data[[nm]]$post == 1]),
         est = ct$Estimate, se = ct$`Std. Error`, p = ct$`Pr(>|t|)`, mde = MDE_K * se)
})
cat("\n  Post-rule change in the probability of reaching 65 among at-risk stars (slack 0-8 at game 62):\n")
pr(reach_tab %>% mutate(across(c(est, se, p, mde), ~ round(.x, 3))))
check(all(reach_tab$p > 0.05), "no pooled at-risk reach-rate change significant at 5% (findings sec. 2)")

# Fisher exact tests by slack bin, healthy at-risk stars
fisher_tab <- ar_healthy %>%
  group_by(slack_bin) %>%
  summarise(n_pre = sum(!post_rule), n_post = sum(post_rule),
            reached_pre = mean(reached[!post_rule]), reached_post = mean(reached[post_rule]),
            p_fisher = fisher.test(table(factor(post_rule, levels = c(FALSE, TRUE)), factor(reached, levels = c(FALSE, TRUE))))$p.value,
            .groups = "drop")
cat("\n  Healthy at-risk stars by slack bin, Fisher exact p-values:\n")
pr(fisher_tab %>% mutate(across(c(reached_pre, reached_post, p_fisher), ~ round(.x, 3))))

# The bound (findings sec. 9). For each season:
#   stars           = star player-seasons
#   at_risk         = slack 0-8 at game 62
#   short_games     = sum over at-risk non-reachers of (65 - final qualifying games):
#                     the fewest extra qualifying games that would have converted every failure
#   max_extra       = sum over at-risk star-seasons of unplayed games after game 62:
#                     every at-risk star plays every remaining game
#   bound_min/max   = those sums divided by the number of stars = the most star mean
#                     qualifying games could rise under full compliance
stars_by_season <- ps %>% filter(star_ppp, !covid) %>% count(season, name = "stars")
bound <- ar %>%
  mutate(short = if_else(at_risk & !reached, RULE_GAMES - qualifying_games, 0),
         played_after_62 = games_played - gp_thru_62,
         max_extra = if_else(at_risk, pmax(games_left - played_after_62, 0), 0)) %>%
  group_by(season, post_rule) %>%
  summarise(n_at_risk = sum(at_risk), n_at_risk_healthy = sum(at_risk & healthy_at_62),
            n_at_risk_not_reached = sum(at_risk & !reached),
            short_games = sum(short), max_extra_games = sum(max_extra), .groups = "drop") %>%
  inner_join(stars_by_season, by = "season") %>%
  mutate(share_at_risk = n_at_risk / stars, bound_min = short_games / stars, bound_max = max_extra_games / stars)
check(all(bound$n_at_risk_not_reached <= bound$n_at_risk & bound$n_at_risk_healthy <= bound$n_at_risk),
      "at-risk subcounts never exceed the at-risk count")

bound_summary <- bound %>%
  group_by(period = if_else(post_rule, "post", "pre")) %>%
  summarise(seasons = n(), stars = mean(stars), n_at_risk = mean(n_at_risk), n_at_risk_not_reached = mean(n_at_risk_not_reached),
            share_at_risk = mean(share_at_risk), bound_min = mean(bound_min), bound_max = mean(bound_max), .groups = "drop")

cat("\n  Per-season at-risk counts and the bound on star mean qualifying games (findings sec. 9: ~1 game):\n")
pr(bound %>% mutate(across(c(share_at_risk, bound_min, bound_max), ~ round(.x, 2))))
cat("\n  Averages:\n")
pr(bound_summary %>% mutate(across(where(is.numeric), ~ round(.x, 2))))

did_upper <- pooled_availability %>% filter(outcome == "qualifying_games", sample == "high_minute_nonstar") %>% pull(hi)
cat("\n  Pre-period minimal bound", round(bound_summary$bound_min[bound_summary$period == "pre"], 2),
    "and maximal bound", round(bound_summary$bound_max[bound_summary$period == "pre"], 2),
    "games; upper 95% limit of the pooled qualifying-games DiD", round(did_upper, 2), "games\n")
check(bound_summary$bound_max[bound_summary$period == "pre"] < did_upper,
      "even the maximal bound lies inside the DiD confidence interval")

# --- Window robustness: slack measured at game 62 or 55, window 0-8 or 0-12 -------------------
panel_stars <- read_rds("data/derived/player_game_panel.rds") %>% filter(star_ppp, !covid)
slack_at <- function(g) panel_stars %>% filter(team_game_no <= g) %>% group_by(season, athlete_id, post_rule) %>%
  summarise(q_thru = sum(qual20) + pmin(sum(qual15), RULE_LOW_ALLOW <- 2), games_left = last(team_games) - g,
            played_after = NA_real_, .groups = "drop") %>% mutate(slack = q_thru + games_left - RULE_GAMES)
gp_after <- function(g) panel_stars %>% group_by(season, athlete_id) %>% summarise(played_after = sum(played & team_game_no > g), .groups = "drop")
finals <- ps %>% select(season, athlete_id, qualifying_games)
bound_window <- function(g, wmax) {
  d <- slack_at(g) %>% select(-played_after) %>% inner_join(gp_after(g), by = c("season", "athlete_id")) %>% inner_join(finals, by = c("season", "athlete_id")) %>%
    mutate(at_risk = slack >= 0 & slack <= wmax, reached = qualifying_games >= RULE_GAMES,
           short = if_else(at_risk & !reached, RULE_GAMES - qualifying_games, 0), max_extra = if_else(at_risk, pmax(games_left - played_after, 0), 0))
  d %>% group_by(season, post_rule) %>% summarise(n_at_risk = sum(at_risk), n_not_reached = sum(at_risk & !reached), short_games = sum(short), max_extra_games = sum(max_extra), .groups = "drop") %>%
    inner_join(stars_by_season, by = "season") %>%
    group_by(period = if_else(post_rule, "post", "pre")) %>%
    summarise(game = g, window = paste0("0-", wmax), seasons = n(), stars = mean(stars), n_at_risk = mean(n_at_risk), share_at_risk = mean(n_at_risk / stars),
              n_not_reached = mean(n_not_reached), bound_min = mean(short_games / stars), bound_max = mean(max_extra_games / stars), .groups = "drop")
}
bound_windows <- bind_rows(bound_window(62, 8), bound_window(62, 12), bound_window(55, 8), bound_window(55, 12)) %>% arrange(game, window, desc(period))
cat("\n  Bound under alternative at-risk windows:\n"); pr(bound_windows %>% mutate(across(where(is.double), ~ round(.x, 2))))
check(abs(bound_windows$bound_min[bound_windows$game == 62 & bound_windows$window == "0-8" & bound_windows$period == "pre"] - bound_summary$bound_min[bound_summary$period == "pre"]) < 0.02,
      "window table reproduces the baseline bound")
write_csv(bound_windows, "results/tables/at_risk_bound_windows.csv")

# Stars with slack >= 9 at game 62 who nonetheless finished below 65 (the shutdown case the 0-8 window excludes)
slack9 <- slack_at(62) %>% select(-played_after) %>% inner_join(finals, by = c("season", "athlete_id")) %>%
  mutate(short = qualifying_games < RULE_GAMES) %>% filter(slack >= 9) %>%
  group_by(season, post_rule) %>% summarise(n_slack9plus = n(), n_short = sum(short), games_short = sum(pmax(RULE_GAMES - qualifying_games, 0)[short]), .groups = "drop") %>%
  inner_join(stars_by_season, by = "season") %>% mutate(bound_add = games_short / stars)
cat("\n  Stars with slack >= 9 at game 62 who finished below 65:\n"); pr(slack9 %>% mutate(bound_add = round(bound_add, 2)))
slack9_summary <- slack9 %>% group_by(period = if_else(post_rule, "post", "pre")) %>% summarise(n_slack9plus = mean(n_slack9plus), n_short = mean(n_short), bound_add = mean(bound_add), .groups = "drop")
pr(slack9_summary %>% mutate(across(where(is.double), ~ round(.x, 2))))
write_csv(slack9, "results/tables/at_risk_slack9plus_short.csv"); write_csv(slack9_summary, "results/tables/at_risk_slack9plus_summary.csv")

# --- Secure and sit: among at-risk stars who reached 65, how many finished at exactly 65? ----------
exact <- ar %>% filter(at_risk, reached) %>% mutate(exact65 = qualifying_games == RULE_GAMES, period = if_else(post_rule, "post", "pre"))
exact_tab <- bind_rows(
  exact %>% group_by(period) %>% summarise(sample = "at-risk reachers", n = n(), n_exact65 = sum(exact65), share_exact65 = mean(exact65), mean_final_qg = mean(qualifying_games), .groups = "drop"),
  exact %>% filter(healthy_at_62) %>% group_by(period) %>% summarise(sample = "healthy at-risk reachers", n = n(), n_exact65 = sum(exact65), share_exact65 = mean(exact65), mean_final_qg = mean(qualifying_games), .groups = "drop"),
  ps %>% filter(star_ppp, !covid, qualifying_games >= RULE_GAMES) %>% mutate(period = if_else(post_rule, "post", "pre")) %>% group_by(period) %>%
    summarise(sample = "all star reachers", n = n(), n_exact65 = sum(qualifying_games == RULE_GAMES), share_exact65 = mean(qualifying_games == RULE_GAMES), mean_final_qg = mean(qualifying_games), .groups = "drop")
) %>% arrange(sample, desc(period))
fisher_exact65 <- exact_tab %>% group_by(sample) %>% summarise(p_fisher = fisher.test(matrix(c(n_exact65[period == "pre"], n[period == "pre"] - n_exact65[period == "pre"],
                                                                                              n_exact65[period == "post"], n[period == "post"] - n_exact65[period == "post"]), 2))$p.value, .groups = "drop")
exact_tab <- exact_tab %>% left_join(fisher_exact65, by = "sample")
cat("\n  Finishing at exactly 65 among reachers (secure and sit):\n"); pr(exact_tab %>% mutate(across(where(is.double), ~ round(.x, 3))))
exact_dist <- exact %>% mutate(final = pmin(qualifying_games, 73), final = if_else(final >= 73, "73+", as.character(final))) %>% count(period, final) %>%
  complete(period, final, fill = list(n = 0L)) %>% group_by(period) %>% mutate(share = n / sum(n)) %>% ungroup() %>% arrange(period, final)
cat("  Distribution of final qualifying games among at-risk reachers:\n"); pr(exact_dist %>% pivot_wider(names_from = period, values_from = c(n, share)) %>% mutate(across(starts_with("share"), ~ round(.x, 2))))
write_csv(exact_tab, "results/tables/at_risk_exact65.csv"); write_csv(exact_dist, "results/tables/at_risk_exact65_distribution.csv")

write_rds(list(reach_models = reach_models, reach = reach_tab, fisher = fisher_tab, bound = bound, bound_summary = bound_summary,
               bound_windows = bound_windows, slack9 = slack9, exact_tab = exact_tab, exact_dist = exact_dist),
          "data/derived/at_risk_bound.rds")
write_csv(reach_tab, "results/tables/at_risk_reach_regressions.csv")
write_csv(fisher_tab, "results/tables/at_risk_fisher.csv")
write_csv(bound, "results/tables/at_risk_bound_by_season.csv")
write_csv(bound_summary, "results/tables/at_risk_bound_summary.csv")

p_bound <- bound %>%
  ggplot(aes(x = season)) +
  annotate("rect", xmin = 2023.5, xmax = 2026.5, ymin = -Inf, ymax = Inf, alpha = 0.08, fill = "firebrick") +
  geom_col(aes(y = n_at_risk), fill = "grey45", width = 0.7) +
  geom_col(aes(y = n_at_risk_not_reached), fill = "grey15", width = 0.7) +
  geom_text(aes(y = n_at_risk, label = stars), vjust = -0.4, size = 3, colour = "grey30") +
  scale_x_continuous(breaks = EST_SEASONS) +
  labs(x = "Season (end year)", y = "Star player-seasons",
       title = "Stars at risk at team game 62: slack of 0 to 8 games",
       subtitle = "Grey: at risk. Black: at risk and did not reach 65. Number above bar: stars that season") +
  theme_minimal(base_size = 12) + theme(panel.grid.minor = element_blank())
ggsave("results/figures/at_risk_by_season.png", p_bound, width = 8, height = 5, dpi = 200)
write_rds(p_bound, "results/figures/at_risk_by_season.rds")
cat("  saved at_risk_reach_regressions.csv, at_risk_fisher.csv, at_risk_bound_*.csv, at_risk_by_season.png\n")

cat("\nDone.\n")
