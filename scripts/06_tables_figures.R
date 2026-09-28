# =============================================================================
# 06_tables_figures.R
#
# NBA 65-game rule: assemble the paper's tables and figures from saved objects.
# Nothing is re-estimated here. Every table is written twice: LaTeX (booktabs,
# via kableExtra) and Markdown (for the draft and for review), to
# results/tables/paper/. Figures are re-saved to results/figures/paper/.
#
# Main text: Tables 1-6, Figures 1-4. Appendix: Tables A1-A6, Figure A1.
# =============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(kableExtra)
})

PROJECT_ROOT <- "/Users/maddockl/nba-65-game-rule"
setwd(PROJECT_ROOT)
SEASONS <- 2014:2026; COVID_SEASONS <- c(2020, 2021); POST_SEASONS <- 2024:2026
EST_SEASONS <- setdiff(SEASONS, COVID_SEASONS); RULE_GAMES <- 65
OUT_T <- "results/tables/paper"; OUT_F <- "results/figures/paper"

stage <- function(txt) cat("\n", strrep("=", 78), "\n", txt, "\n", strrep("=", 78), "\n", sep = "")
check <- function(cond, msg) { if (!isTRUE(cond)) stop("CHECK FAILED: ", msg, call. = FALSE); cat("  ok:", msg, "\n") }
f2 <- function(x, d = 2) ifelse(is.na(x), "", formatC(x, format = "f", digits = d))
est_se <- function(est, se, d = 2) ifelse(is.na(est), "", paste0(f2(est, d), " (", f2(se, d), ")"))
pct <- function(x, d = 1) ifelse(is.na(x), "", paste0(formatC(100 * x, format = "f", digits = d), "%"))

# Write a table as LaTeX and Markdown; return the data frame invisibly
save_table <- function(df, name, caption, note = NULL, align = NULL, col_names = NULL) {
  cn <- if (is.null(col_names)) names(df) else col_names
  k_tex <- kbl(df, format = "latex", booktabs = TRUE, caption = caption, label = name, col.names = cn,
               align = align, linesep = "", escape = TRUE) %>% kable_styling(latex_options = c("hold_position", "scale_down"))
  if (!is.null(note)) k_tex <- k_tex %>% footnote(general = note, general_title = "Note: ", threeparttable = TRUE, escape = TRUE)
  save_kable(k_tex, file.path(OUT_T, paste0(name, ".tex")))
  md <- c(paste0("**", caption, "**"), "", kbl(df, format = "pipe", col.names = cn, align = align), "",
          if (!is.null(note)) paste0("Note: ", note))
  writeLines(md, file.path(OUT_T, paste0(name, ".md")))
  cat("  wrote", name, "\n")
  invisible(df)
}

keys <- list()
key <- function(name, value, source) keys[[length(keys) + 1]] <<- tibble(name = name, value = as.character(value), source = source)


# -----------------------------------------------------------------------------
# 1. LOAD
# -----------------------------------------------------------------------------
stage("STAGE 1: load saved objects")
ps         <- read_rds("data/derived/player_season_clean.rds")
star_flags <- read_rds("data/intermediate/star_flags.rds")
player_box <- read_rds("data/intermediate/player_box.rds")
excluded   <- read_rds("data/derived/excluded_games.rds")
dnp_cov    <- read_rds("data/derived/dnp_row_coverage.rds")
es_avail   <- read_csv("results/tables/es_availability.csv", show_col_types = FALSE)
did_pooled <- read_csv("results/tables/did_availability_pooled.csv", show_col_types = FALSE)
bunch      <- read_rds("data/derived/bunching.rds")
ar_bound   <- read_rds("data/derived/at_risk_bound.rds")
at_risk    <- read_rds("data/derived/at_risk.rds")
rest       <- read_rds("data/derived/rest_tables.rds")
mins       <- read_rds("data/derived/minutes_tables.rds")
absences   <- read_rds("data/derived/long_absences.rds")
bbr_ref    <- read_csv("assets/bbr_validation_manual.csv", show_col_types = FALSE)
cat("  loaded\n")


# -----------------------------------------------------------------------------
# 2. TABLE 1: SAMPLE
# -----------------------------------------------------------------------------
stage("STAGE 2: Table 1 sample")

# Flagged stars with no ESPN appearance in the season (retired or absent all season)
names_lu <- player_box %>% group_by(athlete_id) %>% summarise(name = last(athlete_name), .groups = "drop")
no_appearance <- star_flags %>% filter(star_ppp) %>%
  anti_join(ps %>% select(season, athlete_id), by = c("season", "athlete_id")) %>%
  left_join(names_lu, by = "athlete_id") %>% arrange(season, name)
no_app_by_season <- no_appearance %>% count(season, name = "stars_no_appearance")
cat("  flagged stars with no appearance:\n"); print(no_appearance %>% select(season, name), n = Inf)
write_csv(no_appearance %>% select(season, athlete_id, name), "results/tables/stars_without_appearance.csv")

t1 <- ps %>% filter(!covid) %>% group_by(season) %>%
  summarise(stars = sum(star_ppp),
            gp = mean(games_played[star_ppp]), qg = mean(qualifying_games[star_ppp]),
            ge65 = mean(qualifying_games[star_ppp] >= RULE_GAMES),
            contenders = sum(contender & star_ppp),
            hmns = sum(hm_lag), hmns_gp = mean(games_played[hm_lag]), .groups = "drop") %>%
  left_join(no_app_by_season, by = "season") %>%
  mutate(stars_no_appearance = replace_na(stars_no_appearance, 0L), period = if_else(season %in% POST_SEASONS, "Post", "Pre"))
save_table(
  t1 %>% transmute(Season = season, Period = period, Stars = stars, `No appearance` = stars_no_appearance,
                   `Games played` = f2(gp, 1), `Qualifying games` = f2(qg, 1), `Share >= 65` = f2(ge65, 2),
                   Contenders = contenders, `High-minute non-stars (prior season)` = hmns, `Their games played` = f2(hmns_gp, 1)),
  "tab1_sample", "Sample by season: stars and the primary control group",
  note = paste("Seasons indexed by end year; 2020 and 2021 excluded. Stars: All-Star or All-NBA in any of the prior three seasons",
               "(the PPP definition), with at least one ESPN box-score appearance. 'No appearance': flagged stars with no row in the",
               "season (retired or absent all season). All-Star and Rising Stars rows removed. Games played is the regular-season statistic",
               "and excludes the NBA Cup final; qualifying games follow the rule (>= 20 minutes plus up to two games of 15-19 minutes) and",
               "include the Cup final, so the two can differ by one for players on the finalist teams. Contenders: All-NBA or",
               "any MVP/DPOY vote in the prior season. High-minute non-stars: not a star in the season, and >= 28 minutes per game with",
               ">= 40 games played in the PRIOR season; none defined for 2014."))
key("stars_per_season_range", paste(range(t1$stars), collapse = "-"), "tab1_sample")
key("star_gp_2023", f2(t1$gp[t1$season == 2023], 1), "tab1_sample"); key("star_gp_2024", f2(t1$gp[t1$season == 2024], 1), "tab1_sample")
key("star_ge65_2023", f2(t1$ge65[t1$season == 2023], 2), "tab1_sample"); key("star_ge65_2024", f2(t1$ge65[t1$season == 2024], 2), "tab1_sample")
key("stars_no_appearance_total", sum(t1$stars_no_appearance), "tab1_sample")


# -----------------------------------------------------------------------------
# 3. TABLE 2: SOURCE COVERAGE
# -----------------------------------------------------------------------------
stage("STAGE 3: Table 2 source coverage")
t2 <- dnp_cov %>% select(season, group, team_games, absences, absence_rate, share_absences_with_dnp_row) %>%
  pivot_wider(names_from = group, values_from = c(team_games, absences, absence_rate, share_absences_with_dnp_row))
save_table(
  t2 %>% transmute(Season = season,
                   `Star team-games` = team_games_star, `Star absences` = absences_star,
                   `Star absence rate` = pct(absence_rate_star), `Star absences with a DNP row` = pct(share_absences_with_dnp_row_star, 0),
                   `Non-star team-games` = team_games_high_minute_nonstar, `Non-star absences` = absences_high_minute_nonstar,
                   `Non-star absence rate` = pct(absence_rate_high_minute_nonstar),
                   `Non-star absences with a DNP row` = pct(share_absences_with_dnp_row_high_minute_nonstar, 0)),
  "tab2_source_coverage", "ESPN box-score coverage of absences, by season",
  note = paste("Team-games: every regular-season game of the player's team stint(s). An absence is a team-game the player did not play.",
               "A DNP row is an ESPN box-score line for a player who did not play; it carries a reason string. Absences without a row",
               "carry no information beyond the fact of absence. Non-stars are high-minute non-stars by prior-season status."))
cov_star <- dnp_cov %>% filter(group == "star")
key("dnp_cov_star_2014_2017", paste0(pct(min(cov_star$share_absences_with_dnp_row[cov_star$season <= 2017]), 0), "-",
                                     pct(max(cov_star$share_absences_with_dnp_row[cov_star$season <= 2017]), 0)), "tab2_source_coverage")
key("dnp_cov_star_2023", pct(cov_star$share_absences_with_dnp_row[cov_star$season == 2023], 0), "tab2_source_coverage")
key("dnp_cov_star_post_range", paste0(pct(min(cov_star$share_absences_with_dnp_row[cov_star$season >= 2024]), 0), "-",
                                      pct(max(cov_star$share_absences_with_dnp_row[cov_star$season >= 2024]), 0)), "tab2_source_coverage")
key("star_absence_rate_range", paste0(pct(min(cov_star$absence_rate), 0), "-", pct(max(cov_star$absence_rate), 0)), "tab2_source_coverage")


# -----------------------------------------------------------------------------
# 4. TABLE 3: AVAILABILITY EVENT STUDIES AND POOLED DiDs
# -----------------------------------------------------------------------------
stage("STAGE 4: Table 3 availability")
es_w <- es_avail %>% filter(sample %in% c("high_minute_nonstar", "rotation_nonstar")) %>%
  mutate(cell = est_se(est, se), mde = f2(mde, 1)) %>%
  select(sample, outcome, season, cell, mde) %>%
  pivot_wider(names_from = c(sample, outcome), values_from = c(cell, mde)) %>% arrange(season)
t3a <- es_w %>% transmute(Season = season,
                          `GP: est (SE)` = cell_high_minute_nonstar_games_played, `GP: MDE` = mde_high_minute_nonstar_games_played,
                          `QG: est (SE)` = cell_high_minute_nonstar_qualifying_games, `QG: MDE` = mde_high_minute_nonstar_qualifying_games,
                          `GP, rotation control: est (SE)` = cell_rotation_nonstar_games_played, `GP, rotation: MDE` = mde_rotation_nonstar_games_played)
save_table(t3a, "tab3a_availability_event_study", "Star availability relative to high-minute non-stars, by season (reference 2023)",
           note = paste("Outcomes: games played (GP) and qualifying games (QG) per player-season. Coefficients on star x season, player and",
                        "season fixed effects, SEs clustered by player, 2020-2021 excluded, seasons 2015-2026, no filter on the outcome.",
                        "Control groups are defined by prior-season status: high-minute (>= 28 minutes per game, >= 40 games) or rotation",
                        "(>= 20 minutes, >= 40 games). MDE: minimum detectable effect at 80% power and 5% size (2.80 x SE), in games."))
t3b <- did_pooled %>% filter(sample != "all_nonstar") %>%
  transmute(Outcome = recode(outcome, games_played = "Games played", qualifying_games = "Qualifying games", share_ge65 = "Share >= 65"),
            Control = recode(sample, high_minute_nonstar = "High-minute non-stars (prior season)", rotation_nonstar = "Rotation non-stars (prior season)",
                             contemporaneous = "Exploratory: contemporaneous control, >= 40 rostered games"),
            `Post x star: est (SE)` = est_se(est, se, 3), `95% CI` = paste0("[", f2(lo, 2), ", ", f2(hi, 2), "]"), MDE = f2(mde, 2),
            `Player-seasons` = n, Players = n_clusters)
save_table(t3b, "tab3b_availability_pooled", "Pooled post-rule x star differences in availability",
           note = paste("Post-rule = 2024-2026. Player and season fixed effects; SEs clustered by player. MDE at 80% power. The exploratory",
                        "row conditions the control on games played >= 40 in the same season and drops player-seasons with fewer than 40",
                        "ESPN rows, which removes stars' long-injury seasons; it is shown for comparison only."))
cp <- read_csv("results/tables/did_cohort_pairs.csv", show_col_types = FALSE)
tA9 <- cp %>% transmute(Seasons = pair, `Stars (n)` = n_star, `Stars: first, second` = paste0(f2(star_first, 1), ", ", f2(star_second, 1)),
                        `Controls (n)` = n_ctrl, `Controls: first, second` = paste0(f2(ctrl_first, 1), ", ", f2(ctrl_second, 1)),
                        `DiD: est (SE)` = est_se(est, se), p = f2(p, 2), MDE = f2(mde, 1))
save_table(tA9, "tabA9_cohort_pairs", "Fixed-cohort difference-in-differences for each pair of adjacent seasons, games played",
           note = paste("Groups fixed at their status in the first season of the pair; players present in both seasons; player and season",
                        "fixed effects; SEs clustered by player. The 2023 to 2024 row is the year the rule took effect."))
c24 <- cp %>% filter(pair == "2023->2024")
key("cohort_2024_did", est_se(c24$est, c24$se), "tabA9_cohort_pairs"); key("cohort_2024_p", f2(c24$p, 2), "tabA9_cohort_pairs")
key("cohort_2024_star", paste0(f2(c24$star_first, 1), " to ", f2(c24$star_second, 1)), "tabA9_cohort_pairs"); key("cohort_2024_ctrl", paste0(f2(c24$ctrl_first, 1), " to ", f2(c24$ctrl_second, 1)), "tabA9_cohort_pairs")
key("cohort_2024_n_star", c24$n_star, "tabA9_cohort_pairs"); key("cohort_2024_n_ctrl", c24$n_ctrl, "tabA9_cohort_pairs")
key("cohort_pre_range", paste0(f2(min(cp$est[cp$pair %in% c("2015->2016","2016->2017","2017->2018","2018->2019","2022->2023")])), " to ",
                               f2(max(cp$est[cp$pair %in% c("2015->2016","2016->2017","2017->2018","2018->2019","2022->2023")]))), "tabA9_cohort_pairs")
key("cohort_max_pair", cp$pair[which.max(cp$est)], "tabA9_cohort_pairs"); key("cohort_1516", est_se(cp$est[cp$pair == "2015->2016"], cp$se[cp$pair == "2015->2016"]), "tabA9_cohort_pairs")
key("cohort_2425", est_se(cp$est[cp$pair == "2024->2025"], cp$se[cp$pair == "2024->2025"]), "tabA9_cohort_pairs"); key("cohort_2526", est_se(cp$est[cp$pair == "2025->2026"], cp$se[cp$pair == "2025->2026"]), "tabA9_cohort_pairs")
qr <- read_csv("results/tables/qg_gp_ratio_by_group.csv", show_col_types = FALSE)
key("qg_ratio_rot_2023", f2(qr$ratio_rot_lag[qr$season == 2023], 3), "qg_gp_ratio_by_group.csv"); key("qg_ratio_rot_2024", f2(qr$ratio_rot_lag[qr$season == 2024], 3), "qg_gp_ratio_by_group.csv")
key("qg_ratio_rot_2025", f2(qr$ratio_rot_lag[qr$season == 2025], 3), "qg_gp_ratio_by_group.csv"); key("qg_ratio_star_2023", f2(qr$ratio_star[qr$season == 2023], 3), "qg_gp_ratio_by_group.csv"); key("qg_ratio_star_2024", f2(qr$ratio_star[qr$season == 2024], 3), "qg_gp_ratio_by_group.csv")
key("qg_ratio_hm_2023", f2(qr$ratio_hm_lag[qr$season == 2023], 3), "qg_gp_ratio_by_group.csv"); key("qg_ratio_hm_2024", f2(qr$ratio_hm_lag[qr$season == 2024], 3), "qg_gp_ratio_by_group.csv")
rq <- did_pooled %>% filter(sample == "rotation_nonstar", outcome == "qualifying_games"); key("did_qg_pooled_rot_p", f2(rq$p, 3), "tab3b_availability_pooled")
for (s_ in c(2017, 2024, 2025)) { r <- es_avail %>% filter(sample == "rotation_nonstar", outcome == "qualifying_games", season == s_); key(paste0("es_qg_rot_", s_), est_se(r$est, r$se), "tab3a_availability_event_study") }
r17 <- es_avail %>% filter(sample == "rotation_nonstar", outcome == "games_played", season == 2017); key("es_gp_rot_2017", est_se(r17$est, r17$se), "tab3a_availability_event_study")
cur <- did_pooled %>% filter(sample == "contemporaneous", outcome == "games_played"); key("did_gp_pooled_contemp", est_se(cur$est, cur$se), "tab3b_availability_pooled")
cur24 <- es_avail %>% filter(sample == "contemporaneous", outcome == "games_played", season == 2024); key("es_gp_2024_contemp", est_se(cur24$est, cur24$se), "tab3a_availability_event_study")
gp_p <- did_pooled %>% filter(outcome == "games_played", sample == "high_minute_nonstar")
qg_p <- did_pooled %>% filter(outcome == "qualifying_games", sample == "high_minute_nonstar")
key("did_gp_pooled", est_se(gp_p$est, gp_p$se), "tab3b_availability_pooled"); key("did_gp_pooled_ci", paste0("[", f2(gp_p$lo), ", ", f2(gp_p$hi), "]"), "tab3b_availability_pooled")
key("did_gp_pooled_mde", f2(gp_p$mde, 1), "tab3b_availability_pooled")
key("did_qg_pooled", est_se(qg_p$est, qg_p$se), "tab3b_availability_pooled"); key("did_qg_pooled_hi", f2(qg_p$hi, 1), "tab3b_availability_pooled")
key("did_qg_pooled_mde", f2(qg_p$mde, 1), "tab3b_availability_pooled")
for (s in POST_SEASONS) {
  r <- es_avail %>% filter(sample == "high_minute_nonstar", outcome == "games_played", season == s)
  key(paste0("es_gp_", s), est_se(r$est, r$se), "tab3a_availability_event_study"); key(paste0("es_gp_mde_", s), f2(r$mde, 1), "tab3a_availability_event_study")
}
rot_p <- did_pooled %>% filter(sample == "rotation_nonstar")
key("did_gp_pooled_rot", est_se(rot_p$est[rot_p$outcome == "games_played"], rot_p$se[rot_p$outcome == "games_played"]), "tab3b_availability_pooled")
key("did_qg_pooled_rot", est_se(rot_p$est[rot_p$outcome == "qualifying_games"], rot_p$se[rot_p$outcome == "qualifying_games"]), "tab3b_availability_pooled")
for (s_ in POST_SEASONS) { r <- es_avail %>% filter(sample == "high_minute_nonstar", outcome == "qualifying_games", season == s_); key(paste0("es_qg_", s_), est_se(r$est, r$se), "tab3a_availability_event_study"); key(paste0("es_qg_mde_", s_), f2(r$mde, 1), "tab3a_availability_event_study") }
pre_gp <- es_avail %>% filter(sample == "high_minute_nonstar", outcome == "games_played", season < 2023)
key("es_gp_pre_range", paste0(f2(min(pre_gp$est)), " to ", f2(max(pre_gp$est))), "tab3a_availability_event_study")
key("es_gp_pre_max_mde", f2(max(pre_gp$mde), 1), "tab3a_availability_event_study"); key("es_gp_n_players", (did_pooled %>% filter(sample == "high_minute_nonstar", outcome == "games_played"))$n_clusters, "tab3b_availability_pooled")
key("es_gp_n_ps", (did_pooled %>% filter(sample == "high_minute_nonstar", outcome == "games_played"))$n, "tab3b_availability_pooled")
ge65 <- did_pooled %>% filter(outcome == "share_ge65")
key("did_ge65_pooled", est_se(ge65$est, ge65$se, 3), "tab3b_availability_pooled"); key("did_ge65_mde", f2(ge65$mde, 2), "tab3b_availability_pooled")


# -----------------------------------------------------------------------------
# 5. TABLE 4: BUNCHING
# -----------------------------------------------------------------------------
stage("STAGE 5: Table 4 bunching")
t4a <- bunch$bins %>% transmute(`Qualifying games` = bin, `Pre: n` = n_pre, `Pre: share` = f2(share_pre, 3), `Post: n` = n_post, `Post: share` = f2(share_post, 3))
bt <- bunch$estimates %>% filter(stat %in% c("obs_B", "cf_B", "b", "obs_M", "cf_M", "m")) %>%
  select(counterfactual, window, stat, est, lo, hi) %>%
  pivot_wider(names_from = stat, values_from = c(est, lo, hi))
t4b <- bt %>% transmute(Counterfactual = recode(counterfactual, all_pre = "All pre-rule seasons", recent_pre = "2022-2023 only"),
                        Window = window, `Above: observed` = f2(est_obs_B, 0), `Above: counterfactual` = f2(est_cf_B, 1),
                        `b (95% CI)` = paste0(f2(est_b), " [", f2(lo_b), ", ", f2(hi_b), "]"),
                        `Below: observed` = f2(est_obs_M, 0), `Below: counterfactual` = f2(est_cf_M, 1),
                        `m (95% CI)` = paste0(f2(est_m), " [", f2(lo_m), ", ", f2(hi_m), "]"))
save_table(t4a, "tab4a_bunching_bins", "Star player-seasons around the 65-game threshold, pre- vs post-rule",
           note = "Stars, 2020-2021 excluded. Pre-rule 2014-2019 and 2022-2023; post-rule 2024-2026.")
save_table(t4b, "tab4b_bunching_excess_mass", "Excess mass at and above 65 qualifying games, post-rule stars",
           note = paste("Counterfactual: the pre-rule distribution of stars' qualifying games scaled to the post-rule count. b = excess",
                        "player-seasons in the window above 65 divided by the mean counterfactual mass per one-game bin in that window;",
                        "m likewise for the window below. 95% CIs from 2,000 bootstrap resamples of both distributions."))
bmain <- bt %>% filter(counterfactual == "all_pre")
for (i in seq_len(nrow(bmain))) {
  key(paste0("bunch_b_", i), paste0(f2(bmain$est_b[i]), " [", f2(bmain$lo_b[i]), ", ", f2(bmain$hi_b[i]), "]"), "tab4b_bunching_excess_mass")
  key(paste0("bunch_obs_cf_", i), paste0(f2(bmain$est_obs_B[i], 0), " vs ", f2(bmain$est_cf_B[i], 1)), "tab4b_bunching_excess_mass")
}
brec <- bt %>% filter(counterfactual == "recent_pre", window == "65-68 vs 58-64")
key("bunch_b_recent_wide", paste0(f2(brec$est_b), " [", f2(brec$lo_b), ", ", f2(brec$hi_b), "]"), "tab4b_bunching_excess_mass")
key("bunch_n_pre", bunch$estimates$n_pre[1], "tab4b_bunching_excess_mass"); key("bunch_n_post", bunch$estimates$n_post[1], "tab4b_bunching_excess_mass")
key("bunch_share_post_65_68", f2(bunch$bins$share_post[3], 3), "tab4a_bunching_bins"); key("bunch_share_pre_65_68", f2(bunch$bins$share_pre[3], 3), "tab4a_bunching_bins")
key("bunch_share_post_58_64", f2(bunch$bins$share_post[2], 3), "tab4a_bunching_bins"); key("bunch_share_pre_58_64", f2(bunch$bins$share_pre[2], 3), "tab4a_bunching_bins")


# -----------------------------------------------------------------------------
# 6. TABLE 5: AT-RISK REACH RATES AND THE BOUND
# -----------------------------------------------------------------------------
stage("STAGE 6: Table 5 at-risk")
t5a <- ar_bound$fisher %>% transmute(`Slack at game 62` = slack_bin, `Pre: n` = n_pre, `Pre: reached 65` = f2(reached_pre, 2),
                                     `Post: n` = n_post, `Post: reached 65` = f2(reached_post, 2), `Fisher p` = f2(p_fisher, 2))
t5b <- ar_bound$reach %>% transmute(Sample = recode(sample, all = "All at-risk stars", healthy = "Healthy at game 62",
                                                    healthy_contender = "Healthy, with current-season contention control",
                                                    tight_healthy = "Healthy, slack 0-5"),
                                    n = n, `Post n` = n_post, `Pre reach` = f2(reached_pre, 2), `Post reach` = f2(reached_post, 2),
                                    `Post: est (SE)` = est_se(est, se), MDE = f2(mde, 2))
bs <- ar_bound$bound_summary
t5c <- bs %>% transmute(Period = recode(period, pre = "Pre-rule (8 seasons)", post = "Post-rule (3 seasons)"),
                        `Stars per season` = f2(stars, 1), `At risk per season` = f2(n_at_risk, 1), `Share at risk` = f2(share_at_risk, 2),
                        `Did not reach` = f2(n_at_risk_not_reached, 1), `Bound, minimal crossing` = f2(bound_min, 2),
                        `Bound, play every game` = f2(bound_max, 2))
save_table(t5a, "tab5a_at_risk_reach", "Healthy at-risk stars at team game 62: did they reach 65?",
           note = paste("At risk: 0-8 games of slack at team game 62 (qualifying games so far plus games left minus 65). Healthy: played",
                        "at least two of games 60-62. Reached: >= 65 qualifying games at season end. Fisher exact test of pre vs post."))
save_table(t5b, "tab5b_at_risk_regressions", "Post-rule change in the probability that an at-risk star reaches 65",
           note = "Linear probability models with slack-bin controls; SEs clustered by player. MDE at 80% power, in probability points.")
save_table(t5c, "tab5c_bound", "The maximal-effect bound on star mean qualifying games",
           note = paste("Minimal crossing: every at-risk star who fell short instead reaches exactly 65. Play every game: every at-risk star",
                        "plays every remaining game. Both divided by the number of stars that season and averaged over seasons; units are",
                        "games per star player-season."))
key("bound_min_pre", f2(bs$bound_min[bs$period == "pre"]), "tab5c_bound"); key("bound_max_pre", f2(bs$bound_max[bs$period == "pre"]), "tab5c_bound")
key("bound_min_post", f2(bs$bound_min[bs$period == "post"]), "tab5c_bound"); key("bound_max_post", f2(bs$bound_max[bs$period == "post"]), "tab5c_bound")
key("at_risk_per_season_pre", f2(bs$n_at_risk[bs$period == "pre"], 1), "tab5c_bound"); key("at_risk_per_season_post", f2(bs$n_at_risk[bs$period == "post"], 1), "tab5c_bound")
key("at_risk_share_pre", f2(bs$share_at_risk[bs$period == "pre"], 2), "tab5c_bound")
key("at_risk_range", paste(range(ar_bound$bound$n_at_risk), collapse = "-"), "at_risk_bound_by_season.csv")
rh <- ar_bound$reach %>% filter(sample == "healthy")
key("reach_healthy_est", est_se(rh$est, rh$se), "tab5b_at_risk_regressions"); key("reach_healthy_mde", f2(rh$mde, 2), "tab5b_at_risk_regressions")
key("reach_healthy_n_post", rh$n_post, "tab5b_at_risk_regressions"); key("reach_healthy_pre", f2(rh$reached_pre, 2), "tab5b_at_risk_regressions"); key("reach_healthy_post", f2(rh$reached_post, 2), "tab5b_at_risk_regressions")


# -----------------------------------------------------------------------------
# 7. TABLE 6: ABSENCES OF HEALTHY LATE-SEASON PLAYERS
# -----------------------------------------------------------------------------
stage("STAGE 7: Table 6 absences")
sp <- rest$state_post
t6a <- sp %>% transmute(State = as.character(state), `Pre: n` = n_pre, `Pre: absent` = pct(sat_pre), `Post: n` = n_post, `Post: absent` = pct(sat_post),
                        `Change (SE)` = paste0(f2(100 * change, 1), " (", f2(100 * se_change, 1), ")"),
                        `Pre: with DNP row` = pct(sat_dnp_row_pre), `Post: with DNP row` = pct(sat_dnp_row_post))
save_table(t6a, "tab6a_absence_by_state", "Absence of stars who played the previous game, late season, by eligibility state",
           note = paste("Games 56 onward, full team schedule, 2020-2021 excluded. Absent: did not play, whether or not ESPN printed a row.",
                        "'With DNP row': the part of the absence rate for which ESPN printed a row with a reason. Change in percentage",
                        "points with a binomial SE."))
sr <- rest$state_reg %>% filter(sample == "full schedule")
t6b <- sr %>% filter(!str_detect(term, "unreachable")) %>% transmute(Specification = spec, Term = term %>% str_replace("state::", "") %>% str_replace(":post", " x post") %>% str_replace("no_incentive", "no incentive"),
                        `Est (SE)` = est_se(est, se, 3), p = f2(p, 2), MDE = f2(mde, 3))
save_table(t6b, "tab6b_absence_state_regressions", "State x post-rule regressions of late-season absence, stars",
           note = paste("Player-season and team-game-number fixed effects; SEs clustered by player. Reference state: reachable. MDE at 80% power.",
                        "The unreachable state is omitted: within a player-season its games follow a long absence, so the within-player contrast",
                        "is mechanically negative and the post interaction is identified from few transitions; Table 6a carries that state."))
pr_full <- rest$pooled_rest %>% filter(sample == "full schedule")
t6c <- pr_full %>% transmute(Window = window, `Player-games` = n, `Est (SE)` = est_se(est, se, 3), `95% CI` = paste0("[", f2(lo, 3), ", ", f2(hi, 3), "]"), MDE = f2(mde, 3))
save_table(t6c, "tab6c_absence_star_vs_nonstar", "Star-specific change in late-season absence at the 2017 policy and the 2023 rule",
           note = paste("Stars vs high-minute non-stars who played the previous game, games 56 onward, full schedule. Player, season and",
                        "team-game-number fixed effects; SEs clustered by player. MDE at 80% power."))
rs <- rest$rest_share
key("abs_reach_pre", pct(sp$sat_pre[sp$state == "reachable"]), "tab6a_absence_by_state"); key("abs_reach_post", pct(sp$sat_post[sp$state == "reachable"]), "tab6a_absence_by_state")
key("abs_sec_pre", pct(sp$sat_pre[sp$state == "secured"]), "tab6a_absence_by_state"); key("abs_sec_post", pct(sp$sat_post[sp$state == "secured"]), "tab6a_absence_by_state")
key("abs_unr_pre", pct(sp$sat_pre[sp$state == "unreachable"]), "tab6a_absence_by_state"); key("abs_unr_post", pct(sp$sat_post[sp$state == "unreachable"]), "tab6a_absence_by_state")
key("abs_n_pre_total", sum(sp$n_pre), "tab6a_absence_by_state"); key("abs_n_post_total", sum(sp$n_post), "tab6a_absence_by_state")
for (t in c("state::secured:post", "state::unreachable:post", "no_incentive:post", "state::unreachable")) {
  r <- sr %>% filter(term == t) %>% slice(1)
  key(paste0("reg_", str_replace_all(t, "[:]+", "_")), est_se(r$est, r$se, 3), "tab6b_absence_state_regressions")
  key(paste0("reg_mde_", str_replace_all(t, "[:]+", "_")), f2(r$mde, 3), "tab6b_absence_state_regressions")
}
for (i in seq_len(nrow(pr_full))) { key(paste0("pooled_abs_", i), est_se(pr_full$est[i], pr_full$se[i], 3), "tab6c_absence_star_vs_nonstar"); key(paste0("pooled_abs_mde_", i), f2(pr_full$mde[i], 3), "tab6c_absence_star_vs_nonstar") }
key("rest_lower_bound_pre", pct(rs$share_rest_or_coach_lower_bound[rs$period == "pre"]), "rest_absence_reason_bounds.csv")
key("rest_lower_bound_post", pct(rs$share_rest_or_coach_lower_bound[rs$period == "post"]), "rest_absence_reason_bounds.csv")
key("abs_with_row_pre", pct(rs$with_row[rs$period == "pre"] / rs$absences[rs$period == "pre"], 0), "rest_absence_reason_bounds.csv")
key("abs_with_row_post", pct(rs$with_row[rs$period == "post"] / rs$absences[rs$period == "post"], 0), "rest_absence_reason_bounds.csv")
rr <- rest$raw_rates; key("raw_abs_star_range", paste0(pct(min(rr$sat_star)), "-", pct(max(rr$sat_star))), "rest_raw_by_season.csv")
key("raw_abs_nonstar_range", paste0(pct(min(rr$`sat_non-star`)), "-", pct(max(rr$`sat_non-star`))), "rest_raw_by_season.csv")
rro <- rest$raw_rates_rowsonly; key("rowsonly_star_2014", pct(rro$sat_star[rro$season == 2014]), "rest_raw_by_season_rowsonly.csv"); key("rowsonly_star_2023", pct(rro$sat_star[rro$season == 2023]), "rest_raw_by_season_rowsonly.csv")
tv <- rest$tv_dd; key("tv_ddd", est_se(tv$est, tv$se, 3), "rest_tv_ddd.csv")


# -----------------------------------------------------------------------------
# 8. APPENDIX TABLES
# -----------------------------------------------------------------------------
stage("STAGE 8: appendix tables")
# A1: star x season absence event studies (full schedule ref 2023 & 2017; rows-only ref 2023)
esr <- rest$es_rest %>% mutate(cell = est_se(est, se, 3), mde = f2(mde, 3)) %>%
  filter(!(sample == "rows only" & ref == 2017)) %>%
  select(sample, ref, season, cell, mde) %>% pivot_wider(names_from = c(sample, ref), values_from = c(cell, mde)) %>% arrange(season)
tA1 <- esr %>% transmute(Season = season, `Full, ref 2023: est (SE)` = `cell_full schedule_2023`, MDE = `mde_full schedule_2023`,
                         `Full, ref 2017: est (SE)` = `cell_full schedule_2017`, `MDE ` = `mde_full schedule_2017`,
                         `ESPN rows only, ref 2023: est (SE)` = `cell_rows only_2023`, `MDE  ` = `mde_rows only_2023`)
save_table(tA1, "tabA1_absence_event_study", "Star minus non-star late-season absence by season",
           note = paste("Coefficients on star x season; player, season and team-game-number fixed effects; SEs clustered by player.",
                        "'ESPN rows only' reproduces the exploratory construction in which only games with an ESPN row enter."))
esf <- rest$es_rest %>% filter(sample == "full schedule", ref == 2023)
for (s in POST_SEASONS) { r <- esf %>% filter(season == s); key(paste0("es_abs_", s), est_se(r$est, r$se, 3), "tabA1_absence_event_study"); key(paste0("es_abs_mde_", s), f2(r$mde, 3), "tabA1_absence_event_study") }
r14 <- esf %>% filter(season == 2014); key("es_abs_2014", est_se(r14$est, r14$se, 3), "tabA1_absence_event_study"); key("es_abs_2014_p", f2(r14$p, 3), "tabA1_absence_event_study")
r22 <- esf %>% filter(season == 2022); key("es_abs_2022", est_se(r22$est, r22$se, 3), "tabA1_absence_event_study")
gl <- rest$gap_by_season %>% filter(sample == "full schedule", spec == "gap level"); key("gap_level_range", paste0(f2(min(gl$est), 3), " to ", f2(max(gl$est), 3)), "rest_gap_by_season.csv")
ro <- rest$es_rest %>% filter(sample == "rows only", ref == 2023, season == 2026); key("rowsonly_es_2026", est_se(ro$est, ro$se, 3), "tabA1_absence_event_study")

# A2: minute bins
mb <- mins$all$long %>% mutate(txt = paste0(f2(share, 3), " (", n, ")")) %>% select(min_bin, cell, txt) %>% pivot_wider(names_from = cell, values_from = txt)
mb2 <- mins$no_recent_return$long %>% mutate(txt = paste0(f2(share, 3), " (", n, ")")) %>% select(min_bin, cell, txt) %>% pivot_wider(names_from = cell, values_from = txt)
tA2 <- bind_rows(mb %>% mutate(Sample = "All"), mb2 %>% mutate(Sample = "Played each of previous 3 games")) %>%
  select(Sample, `Minutes` = min_bin, everything())
save_table(tA2, "tabA2_minute_bins", "Minutes played by late-season stars, by slack: share of player-games (cell count)",
           note = paste("Stars who played, games 56 onward, 2020-2021 excluded. Tight: 0-3 games of slack and 65 not yet secured.",
                        "Cell counts in parentheses. Confounded by minute restrictions on players returning from injury."))
ms <- mins$summary %>% filter(sample == "all")
key("h4_post_tight_n", ms$n[ms$cell == "post, tight"], "tabA2_minute_bins"); key("h4_post_tight_players", ms$players[ms$cell == "post, tight"], "tabA2_minute_bins")
key("h4_share2030_pre_tight", f2(ms$share_20_30[ms$cell == "pre, tight"], 2), "minutes_summary.csv"); key("h4_share2030_post_tight", f2(ms$share_20_30[ms$cell == "post, tight"], 2), "minutes_summary.csv")
key("h4_share2030_post_nottight", f2(ms$share_20_30[ms$cell == "post, not tight"], 2), "minutes_summary.csv"); key("h4_share2030_pre_nottight", f2(ms$share_20_30[ms$cell == "pre, not tight"], 2), "minutes_summary.csv")
key("h4_se_post_tight", f2(ms$se_20_30[ms$cell == "post, tight"], 2), "minutes_summary.csv")
ms2 <- mins$summary %>% filter(sample != "all"); key("h4_share2030_post_tight_nrr", f2(ms2$share_20_30[ms2$cell == "post, tight"], 2), "minutes_summary.csv"); key("h4_share2030_pre_tight_nrr", f2(ms2$share_20_30[ms2$cell == "pre, tight"], 2), "minutes_summary.csv")

# A3: long absences
ab_all <- absences$summary %>% mutate(group = factor(group, levels = c("star", "high_minute_nonstar")), period = factor(period, levels = c("pre", "post"))) %>% arrange(group, period)
ab <- ab_all %>% filter(group == "star")
tA3 <- ab_all %>% transmute(Group = recode(as.character(group), star = "Stars", high_minute_nonstar = "High-minute non-stars (prior season)"),
                        Period = recode(as.character(period), pre = "Pre-rule", post = "Post-rule"), `Player-seasons` = star_seasons, Spells = spells,
                        `Spells per star-season` = f2(spells_per_star_season, 2), `Star-seasons with a spell` = pct(share_star_seasons_with_spell, 0),
                        `Mean length` = f2(mean_length, 1), `Games lost per star-season` = f2(games_missed_per_star_season, 1),
                        `Censored at season end` = pct(share_censored, 0), `Reason: injury/illness` = pct(share_injury, 0),
                        `Reason: no row` = pct(share_no_reason, 0), `Reason: rest or coach` = pct(share_rest_or_coach, 0),
                        `Begin games 1-20` = pct(share_start_1_20, 0), `21-40` = pct(share_start_21_40, 0), `41-55` = pct(share_start_41_55, 0), `56-82` = pct(share_start_56_82, 0))
save_table(tA3, "tabA3_long_absences", "Spells of 10 or more consecutive missed games, stars and high-minute non-stars",
           note = paste("Full team schedule, 2020-2021 excluded. Reason taken from the first game in the spell for which ESPN printed a row;",
                        "'no row' spells have no ESPN row at any point."))
rise <- read_csv("results/tables/absences_rise_by_group.csv", show_col_types = FALSE)
for (g in rise$group) {
  r <- rise %>% filter(group == g)
  key(paste0("spell_ratio_", g), f2(r$ratio_spells, 2), "absences_rise_by_group.csv")
  key(paste0("spells_per_ss_pre_", g), f2(r$spells_per_star_season_pre, 2), "tabA3_long_absences"); key(paste0("spells_per_ss_post_", g), f2(r$spells_per_star_season_post, 2), "tabA3_long_absences")
  key(paste0("spells_start_late_pre_", g), pct(r$share_start_56_82_pre, 0), "tabA3_long_absences"); key(paste0("spells_start_late_post_", g), pct(r$share_start_56_82_post, 0), "tabA3_long_absences")
}
abn <- ab_all %>% filter(group == "high_minute_nonstar")
key("spells_share_ss_pre_nonstar", pct(abn$share_star_seasons_with_spell[abn$period == "pre"], 0), "tabA3_long_absences"); key("spells_share_ss_post_nonstar", pct(abn$share_star_seasons_with_spell[abn$period == "post"], 0), "tabA3_long_absences")
key("spells_share_ss_pre_star", pct(ab$share_star_seasons_with_spell[ab$period == "pre"], 0), "tabA3_long_absences"); key("spells_share_ss_post_star", pct(ab$share_star_seasons_with_spell[ab$period == "post"], 0), "tabA3_long_absences")
abs_season <- absences$by_season
for (g in c("star", "high_minute_nonstar")) for (yr in c(2023, 2024, 2025, 2026)) {
  r <- abs_season %>% filter(group == g, season == yr); key(paste0("spells_per_ss_", g, "_", yr), f2(r$spells_per_star_season, 2), "absences_by_season.csv")
}

# Composition of the 2023 -> 2024 change in star means
compo <- read_csv("results/tables/composition_2024.csv", show_col_types = FALSE)
tA8 <- compo %>% transmute(Outcome = recode(outcome, games_played = "Stars: games played", qualifying_games = "Stars: qualifying games", games_played_control = "High-minute non-stars (prior season): games played"),
                           `Mean 2023 (n)` = paste0(f2(mean_2023, 1), " (", n_2023, ")"), `Mean 2024 (n)` = paste0(f2(mean_2024, 1), " (", n_2024, ")"), `Raw change` = f2(raw_change, 1),
                           `Stayers: n` = n_stayers, `Stayers 2023` = f2(stayers_2023, 1), `Stayers 2024` = f2(stayers_2024, 1), `Stayers change` = f2(stayers_change, 1),
                           `Entrants 2024 (n)` = paste0(f2(entrants_2024, 1), " (", n_entrants, ")"), `Leavers 2023 (n)` = paste0(f2(leavers_2023, 1), " (", n_leavers, ")"))
save_table(tA8, "tabA8_composition_2024", "Decomposition of the 2023 to 2024 change in mean games: stayers, entrants and leavers",
           note = paste("Stayers are players in the group in both seasons; entrants are 2024 members who were not members in 2023; leavers are",
                        "2023 members who were not members in 2024. The within-player event-study coefficient is identified from stayers."))
cg <- compo %>% filter(outcome == "games_played"); cc <- compo %>% filter(outcome == "games_played_control")
key("comp_star_raw_change", f2(cg$raw_change, 1), "tabA8_composition_2024"); key("comp_star_stayers_change", f2(cg$stayers_change, 1), "tabA8_composition_2024")
key("comp_star_n_stayers", cg$n_stayers, "tabA8_composition_2024"); key("comp_star_stayers_2023", f2(cg$stayers_2023, 1), "tabA8_composition_2024"); key("comp_star_stayers_2024", f2(cg$stayers_2024, 1), "tabA8_composition_2024")
key("comp_star_entrants_2024", f2(cg$entrants_2024, 1), "tabA8_composition_2024"); key("comp_star_n_entrants", cg$n_entrants, "tabA8_composition_2024")
key("comp_star_leavers_2023", f2(cg$leavers_2023, 1), "tabA8_composition_2024"); key("comp_star_n_leavers", cg$n_leavers, "tabA8_composition_2024")
key("comp_control_raw_change", f2(cc$raw_change, 1), "tabA8_composition_2024"); key("comp_control_stayers_change", f2(cc$stayers_change, 1), "tabA8_composition_2024")
key("comp_raw_did", f2(cg$raw_change - cc$raw_change, 1), "tabA8_composition_2024"); key("comp_stayer_did", f2(cg$stayers_change - cc$stayers_change, 1), "tabA8_composition_2024")
key("spells_pre", ab$spells[ab$period == "pre"], "tabA3_long_absences"); key("spells_post", ab$spells[ab$period == "post"], "tabA3_long_absences")
key("spells_per_ss_pre", f2(ab$spells_per_star_season[ab$period == "pre"], 2), "tabA3_long_absences"); key("spells_per_ss_post", f2(ab$spells_per_star_season[ab$period == "post"], 2), "tabA3_long_absences")
key("spells_rest_coach_pre", pct(ab$share_rest_or_coach[ab$period == "pre"], 0), "tabA3_long_absences"); key("spells_rest_coach_post", pct(ab$share_rest_or_coach[ab$period == "post"], 0), "tabA3_long_absences")
key("spells_games_lost_pre", f2(ab$games_missed_per_star_season[ab$period == "pre"], 1), "tabA3_long_absences"); key("spells_games_lost_post", f2(ab$games_missed_per_star_season[ab$period == "post"], 1), "tabA3_long_absences")
key("spells_start_late_pre", pct(ab$share_start_56_82[ab$period == "pre"], 0), "tabA3_long_absences"); key("spells_start_late_post", pct(ab$share_start_56_82[ab$period == "post"], 0), "tabA3_long_absences")

# A4: absence composition (reasons)
tA4 <- rest$reasons %>% mutate(period = factor(period, levels = c("pre", "post"))) %>% arrange(period, desc(n)) %>%
  transmute(Period = recode(as.character(period), pre = "Pre-rule", post = "Post-rule"), Class = class, n = n, Share = pct(share))
save_table(tA4, "tabA4_absence_reasons", "What ESPN says about late-season absences of stars who played the previous game",
           note = "Classes from the DNP reason string. Absences with no ESPN row carry no reason.")

# A5: BBR validation
tA5 <- bbr_ref %>% left_join(ps %>% select(season, athlete_name, games_played, games_played_orig, games_played_rule, qualifying_games), by = c("season", "espn_name" = "athlete_name")) %>%
  mutate(status = case_when(is.na(games_played) & bbr_games_played == 0 ~ "no ESPN rows; not in sample",
                            is.na(games_played) ~ "NOT FOUND", games_played == bbr_games_played ~ "match", TRUE ~ "MISMATCH")) %>%
  transmute(Season = season, Player = player, `Reference games played` = bbr_games_played, `This paper: regular season` = f2(games_played, 0),
            `Raw ESPN count` = f2(games_played_orig, 0), `Games under the rule (incl. Cup final)` = f2(games_played_rule, 0), `Qualifying games` = f2(qualifying_games, 0), Status = status, Source = source)
save_table(tA5, "tabA5_bbr_validation", "Games played: ten star-seasons checked against Basketball-Reference",
           note = paste("Reference values from cached Basketball-Reference award-voting tables where available, otherwise from a web lookup on the date shown.",
                        "Regular-season games exclude the All-Star game and the NBA Cup final, as Basketball-Reference does; the rule's count includes the Cup final."))
check(!any(tA5$Status %in% c("MISMATCH", "NOT FOUND")), "no games-played mismatches against the reference values")
key("bbr_matches", sum(tA5$Status == "match"), "tabA5_bbr_validation")

# A6: stars without any appearance
tA6 <- no_appearance %>% group_by(season) %>% summarise(Players = paste(name, collapse = "; "), .groups = "drop") %>% transmute(Season = season, `Flagged stars with no ESPN appearance` = Players)
save_table(tA6, "tabA6_stars_no_appearance", "Flagged stars absent from the sample: no ESPN box-score row in the season",
           note = "Retired players and players who missed the entire season. They do not enter any player-season count.")

# Table 5d: one row per healthy at-risk star-season, post-rule, with the return pattern after the
# last pre-game-62 absence and a hand-coded stakes column (assets/stakes_manual.csv).
ar_post <- at_risk %>% filter(post_rule, at_risk, healthy_at_62)
panel_post <- read_rds("data/derived/player_game_panel.rds") %>% filter(star_ppp, post_rule) %>% semi_join(ar_post, by = c("season", "athlete_id"))
returns <- panel_post %>% arrange(season, athlete_id, player_game_no) %>% group_by(season, athlete_id) %>%
  summarise(last_absence_before_62 = { a <- team_game_no[sat & team_game_no < 62]; if (length(a)) max(a) else NA_integer_ },
            absences_before_62 = sum(sat & team_game_no < 62),
            minutes_first_4_after_return = { g <- if (is.na(last_absence_before_62)) integer(0) else head(which(played & team_game_no > last_absence_before_62), 4)
                                             if (length(g)) paste(round(minutes[g]), collapse = ", ") else "" },
            return_team_games = { g <- if (is.na(last_absence_before_62)) integer(0) else head(which(played & team_game_no > last_absence_before_62), 4)
                                  if (length(g)) paste(team_game_no[g], collapse = ", ") else "" },
            .groups = "drop")
stakes <- read_csv("assets/stakes_manual.csv", show_col_types = FALSE)
# Players who received votes in any cached award-voting table (MVP, DPOY, MIP, 6MOY, All-NBA, All-Defense)
# in a post-rule season: receiving votes implies the league treated them as eligible.
suppressPackageStartupMessages({library(rvest); library(janitor)})
bbr_tabs <- function(page) {
  visible <- page %>% html_elements("table")
  hidden  <- page %>% html_elements(xpath = "//comment()") %>% html_text() %>% keep(~ str_detect(.x, "<table")) %>% map(~ read_html(.x) %>% html_elements("table")) %>% flatten()
  tabs <- c(visible, hidden); set_names(tabs, map_chr(tabs, ~ coalesce(html_attr(.x, "id"), "")))
}
votes <- map_dfr(POST_SEASONS, function(yr) {
  tabs <- bbr_tabs(read_html(sprintf("data/raw/bbr/awards_%d.html", yr)))
  map_dfr(names(tabs), function(id) {
    t <- tryCatch(tabs[[id]] %>% html_table() %>% row_to_names(1) %>% clean_names(), error = function(e) NULL)
    if (is.null(t) || !all(c("player", "g") %in% names(t))) return(tibble())
    t %>% transmute(season = yr, table = id, player = stringi::stri_trans_general(player, "Latin-ASCII"), g = suppressWarnings(as.integer(g)))
  })
}) %>% filter(!is.na(g), !table %in% c("clutch_poy", "roy", "leading_all_rookie")) %>%   # awards not subject to the 65-game rule
  group_by(season, player) %>% summarise(bbr_games = first(g), vote_tables = paste(unique(table), collapse = "; "), .groups = "drop")
t5d <- ar_post %>% left_join(returns, by = c("season", "athlete_id")) %>%
  left_join(stakes, by = c("season", "athlete_name" = "player")) %>%
  mutate(name_key = stringi::stri_trans_general(athlete_name, "Latin-ASCII") %>% str_remove(" III$| Jr\\.$")) %>%
  left_join(votes, by = c("season", "name_key" = "player")) %>%
  mutate(received_award_votes = !is.na(vote_tables), vote_tables = replace_na(vote_tables, "")) %>%
  transmute(season, player = athlete_name, slack_at_62, qualifying_thru_62 = q_thru_62, contender_prior_season = contender,
            contender_current_proxy = contender_cur, reached_65 = reached, final_qualifying_games = qualifying_games, games_played,
            last_absence_before_62, absences_before_62, return_team_games, minutes_first_4_after_return,
            received_award_votes, bbr_games, vote_tables,
            stakes = replace_na(stakes, ""), stakes_source = replace_na(stakes_source, "")) %>%
  arrange(season, slack_at_62, player)
write_csv(t5d, file.path(OUT_T, "tab5d_case_table.csv"))
save_table(t5d %>% select(-stakes_source, -contender_current_proxy, -games_played, -return_team_games, -bbr_games, -vote_tables),
           "tab5d_case_table", "Healthy at-risk stars in the post-rule seasons: slack at game 62, outcome, return minutes, and stakes",
           note = paste("At risk: 0-8 games of slack at team game 62; healthy: played at least two of games 60-62. Return minutes: minutes in the",
                        "first four appearances after the player's last absence before team game 62. Stakes are hand-coded from press coverage",
                        "and the CBA; entries marked for verification in the csv should be checked against Spotrac before use."))
cat("  Table 5d rows (healthy at-risk post-rule star-seasons):", nrow(t5d), "\n"); key("t5d_rows", nrow(t5d), "tab5d_case_table")
check(nrow(t5d) >= 18 & nrow(t5d) <= 26, "Table 5d has one row per healthy at-risk post-rule star-season (about 22)")
hal <- t5d %>% filter(season == 2024, str_detect(player, "Haliburton"))
check(hal$minutes_first_4_after_return == "22, 22, 22, 20", "Haliburton 2024 return minutes are 22, 22, 22, 20 (Forbes account)")
below_with_votes <- t5d %>% filter(!reached_65, received_award_votes)
cat("  at-risk stars below 65 who nonetheless received award votes:\n"); print(below_with_votes %>% select(season, player, final_qualifying_games, bbr_games, vote_tables))
key("t5d_below65_with_votes", nrow(below_with_votes), "tab5d_case_table")

# A10: bound under alternative at-risk windows; slack >= 9 shutdown cases
bw <- ar_bound$bound_windows
tA10 <- bw %>% transmute(`Slack measured at game` = game, Window = window, Period = recode(period, pre = "Pre-rule", post = "Post-rule"),
                         `At risk per season` = f2(n_at_risk, 1), `Share of stars` = f2(share_at_risk, 2), `Did not reach` = f2(n_not_reached, 1),
                         `Bound, minimal crossing` = f2(bound_min, 2), `Bound, play every game` = f2(bound_max, 2))
save_table(tA10, "tabA10_bound_windows", "The maximal-effect bound under alternative definitions of the at-risk population",
           note = "Same construction as Table 5c with slack measured at team game 62 or 55 and the window widened to 0-12 games.")
for (i in seq_len(nrow(bw))) key(paste0("bw_", bw$game[i], "_", bw$window[i], "_", bw$period[i]), paste0(f2(bw$bound_min[i]), " / ", f2(bw$bound_max[i]), " (", f2(bw$n_at_risk[i], 1), " at risk)"), "tabA10_bound_windows")
s9 <- read_csv("results/tables/at_risk_slack9plus_summary.csv", show_col_types = FALSE)
key("slack9_short_pre", f2(s9$n_short[s9$period == "pre"], 1), "at_risk_slack9plus_summary.csv"); key("slack9_short_post", f2(s9$n_short[s9$period == "post"], 1), "at_risk_slack9plus_summary.csv")
key("slack9_bound_add_pre", f2(s9$bound_add[s9$period == "pre"], 2), "at_risk_slack9plus_summary.csv"); key("slack9_n_pre", f2(s9$n_slack9plus[s9$period == "pre"], 1), "at_risk_slack9plus_summary.csv")

# A11: secure and sit
ex <- ar_bound$exact_tab
tA11 <- ex %>% transmute(Sample = sample, Period = recode(period, pre = "Pre-rule", post = "Post-rule"), n = n, `Finished at exactly 65` = n_exact65,
                         Share = f2(share_exact65, 2), `Mean final qualifying games` = f2(mean_final_qg, 1), `Fisher p` = f2(p_fisher, 2))
save_table(tA11, "tabA11_exact65", "Finishing at exactly 65 qualifying games among stars who reached the line",
           note = "At-risk: 0-8 games of slack at team game 62. Healthy: played at least two of games 60-62. Fisher exact test of pre vs post within sample.")
for (i in seq_len(nrow(ex))) key(paste0("exact65_", str_replace_all(ex$sample[i], "[ -]", "_"), "_", ex$period[i]), paste0(ex$n_exact65[i], " of ", ex$n[i], " (", f2(ex$share_exact65[i], 2), ")"), "tabA11_exact65")
for (smp in unique(ex$sample)) key(paste0("exact65_p_", str_replace_all(smp, "[ -]", "_")), f2(ex$p_fisher[ex$sample == smp][1], 2), "tabA11_exact65")
exd <- ar_bound$exact_dist %>% pivot_wider(names_from = period, values_from = c(n, share))
tA11b <- exd %>% transmute(`Final qualifying games` = final, `Pre: n` = n_pre, `Pre: share` = f2(share_pre, 2), `Post: n` = n_post, `Post: share` = f2(share_post, 2))
save_table(tA11b, "tabA11b_exact65_distribution", "Final qualifying games of at-risk stars who reached 65")

# A12: 20-minute share of appearances, stars vs control
s20 <- read_csv("results/tables/minutes_share20_es.csv", show_col_types = FALSE)
s20raw <- read_csv("results/tables/minutes_share20_raw.csv", show_col_types = FALSE)
tA12 <- s20 %>% filter(!is.na(season)) %>% mutate(cell = est_se(est, se, 3), mde = f2(mde, 3)) %>% select(sample, season, cell, mde) %>%
  pivot_wider(names_from = sample, values_from = c(cell, mde)) %>% arrange(season) %>%
  left_join(s20raw %>% select(season, share20_star, share20_high_minute_nonstar), by = "season") %>%
  transmute(Season = season, `Stars: share 20+ min` = f2(share20_star, 3), `Control: share 20+ min` = f2(share20_high_minute_nonstar, 3),
            `All games: star x season (SE)` = `cell_all games`, MDE = `mde_all games`, `Late season: star x season (SE)` = `cell_late season`, `MDE ` = `mde_late season`)
s20nofe <- read_csv("results/tables/minutes_share20_es_nofe.csv", show_col_types = FALSE)
tA12 <- tA12 %>% left_join(s20nofe %>% transmute(Season = season, `All games, no player FE: star x season (SE)` = est_se(est, se, 3)), by = "Season") %>%
  select(Season, `Stars: share 20+ min`, `Control: share 20+ min`, `All games, no player FE: star x season (SE)`, everything())
save_table(tA12, "tabA12_share20_event_study", "Share of appearances lasting at least 20 minutes: stars relative to the control group",
           note = paste("Player-games in which the player appeared, stars and lagged high-minute non-stars, 2015-2026 excluding 2020-2021. Coefficients on",
                        "star x season relative to 2023; player, season and team-game-number fixed effects; SEs clustered by player."))
sp <- read_csv("results/tables/minutes_share20_specs.csv", show_col_types = FALSE); rd <- read_csv("results/tables/minutes_share20_raw_did.csv", show_col_types = FALSE)
sb <- read_csv("results/tables/minutes_sub20_by_period.csv", show_col_types = FALSE)
tA15 <- bind_rows(
  rd %>% transmute(Comparison = paste0("Raw difference-in-differences, pre-period ", pre_period), `Estimate (SE)` = f2(raw_did, 3), p = "", MDE = "",
                   Detail = paste0("stars ", f2(star_pre, 3), " to ", f2(star_post, 3), "; control ", f2(ctrl_pre, 3), " to ", f2(ctrl_post, 3))),
  sp %>% transmute(Comparison = spec, `Estimate (SE)` = est_se(est, se, 3), p = f2(p, 3), MDE = f2(mde, 3), Detail = paste0(format(n, big.mark = ","), " appearances")))
save_table(tA15, "tabA15_share20_specs", "Post-rule change in the share of star appearances of 20 or more minutes: raw comparisons and alternative specifications",
           note = paste("Appearances by stars and lagged high-minute non-stars, 2015-2026 excluding 2020-2021. Regression rows report the coefficient on",
                        "post-rule x star with SEs clustered by player. Never-switchers are players who are stars in every season they appear or controls in every season."))
for (i in seq_len(nrow(rd))) key(paste0("share20_rawdid_", rd$pre_period[i]), f2(rd$raw_did[i], 3), "tabA15_share20_specs")
key("share20_star_pre_pooled", f2(rd$star_pre[1], 3), "tabA15_share20_specs"); key("share20_star_post_pooled", f2(rd$star_post[1], 3), "tabA15_share20_specs")
key("share20_ctrl_pre_pooled", f2(rd$ctrl_pre[1], 3), "tabA15_share20_specs"); key("share20_ctrl_post_pooled", f2(rd$ctrl_post[1], 3), "tabA15_share20_specs")
for (i in seq_len(nrow(sp))) key(paste0("share20_spec_", i), paste0(sp$spec[i], ": ", est_se(sp$est[i], sp$se[i], 3), ", p = ", f2(sp$p[i], 3)), "tabA15_share20_specs")
for (i in seq_len(nrow(sb))) key(paste0("sub20_", sb$group[i], "_", sb$period[i]), f2(sb$sub20_per_player_season[i], 2), "minutes_sub20_by_period.csv")
for (yr in c(2024, 2025, 2026)) { r <- s20nofe %>% filter(season == yr); key(paste0("share20_es_nofe_", yr), est_se(r$est, r$se, 3), "tabA12_share20_event_study") }
key("share20_es_nofe_pre_min", f2(min(s20nofe$est[s20nofe$season < 2023]), 3), "tabA12_share20_event_study")

# Rows-only raw rates (exploratory construction), for the data-section note
rro_tab <- rest$raw_rates_rowsonly %>% transmute(Season = season, `Stars: share sat (ESPN rows only)` = f2(sat_star, 3), `Contemporaneous control: share sat (ESPN rows only)` = f2(`sat_non-star`, 3),
                                                 `Star player-games` = n_star, `Control player-games` = `n_non-star`)
save_table(rro_tab, "tabA16_rowsonly_raw", "Late-season 'rest' rates computed on ESPN rows only (exploratory construction)",
           note = paste("Player-games with an ESPN row whose previous ESPN row was a game played, games 56 onward; the outcome is a did-not-play row. This construction",
                        "omits inactive-list absences and tracks roster designation (Table 2); it is shown only to document the earlier numbers."))

p20 <- s20 %>% filter(is.na(season))
for (i in seq_len(nrow(p20))) { key(paste0("share20_pooled_", str_replace(p20$sample[i], " ", "_")), est_se(p20$est[i], p20$se[i], 3), "minutes_share20_es.csv"); key(paste0("share20_pooled_mde_", str_replace(p20$sample[i], " ", "_")), f2(p20$mde[i], 3), "minutes_share20_es.csv"); key(paste0("share20_pooled_p_", str_replace(p20$sample[i], " ", "_")), f2(p20$p[i], 3), "minutes_share20_es.csv") }
for (yr in c(2024, 2025, 2026)) { r <- s20 %>% filter(sample == "all games", season == yr); key(paste0("share20_es_", yr), est_se(r$est, r$se, 3), "tabA12_share20_event_study") }
for (yr in c(2019, 2022, 2023, 2024, 2025, 2026)) { key(paste0("share20_star_", yr), f2(s20raw$share20_star[s20raw$season == yr], 3), "tabA12_share20_event_study"); key(paste0("share20_ctrl_", yr), f2(s20raw$share20_high_minute_nonstar[s20raw$season == yr], 3), "tabA12_share20_event_study") }
pre20 <- s20 %>% filter(sample == "all games", !is.na(season), season < 2023); key("share20_pre_max_abs", f2(max(abs(pre20$est)), 3), "tabA12_share20_event_study"); key("share20_pre_min_p", f2(min(pre20$p), 3), "tabA12_share20_event_study")

# A13: late-onset spell test
lc <- read_csv("results/tables/absences_late_onset_cells.csv", show_col_types = FALSE); ld <- read_csv("results/tables/absences_late_onset_dd.csv", show_col_types = FALSE)
tA13 <- lc %>% mutate(group = factor(group, levels = c("star", "high_minute_nonstar")), period = factor(period, levels = c("pre", "post"))) %>% arrange(group, period) %>%
  transmute(Group = recode(as.character(group), star = "Stars", high_minute_nonstar = "High-minute non-stars (prior season)"), Period = recode(as.character(period), pre = "Pre-rule", post = "Post-rule"),
            Spells = n, `Beginning at game 56+` = n_late, Share = f2(share, 2), `Fisher p (pre vs post)` = f2(p_fisher, 2))
save_table(tA13, "tabA13_late_onset", "Long absences beginning in the late-season window, before and after the rule",
           note = paste0("Difference in shares, stars minus control, post minus pre: ", f2(ld$est, 3), " with bootstrap 95% interval [", f2(ld$lo, 3), ", ", f2(ld$hi, 3), "] from 2,000 resamples of spells within group and period."))
key("late_onset_dd", paste0(f2(ld$est, 3), " [", f2(ld$lo, 3), ", ", f2(ld$hi, 3), "]"), "tabA13_late_onset")
for (i in seq_len(nrow(lc))) key(paste0("late_onset_", lc$group[i], "_", lc$period[i]), paste0(lc$n_late[i], " of ", lc$n[i]), "tabA13_late_onset")
for (g in unique(lc$group)) key(paste0("late_onset_p_", g), f2(lc$p_fisher[lc$group == g][1], 2), "tabA13_late_onset")

# A14: BBR box-score check of the inactive-list mechanism (if script 07 has run)
if (file.exists("results/tables/bbr_boxscore_check.csv")) {
  bb <- read_csv("results/tables/bbr_boxscore_check.csv", show_col_types = FALSE) %>% filter(status == "ok")
  tA14 <- bb %>% transmute(Season = season, Game = as.character(game_date), `ESPN rows` = espn_rows, `BBR box rows` = bbr_table_rows, `ESPN rows found in BBR box` = espn_rows_in_bbr_table,
                           `ESPN DNP rows` = espn_dnp_rows, `Of which BBR did-not-play` = espn_dnp_in_bbr_dnp, `BBR inactive` = bbr_inactive, `BBR inactive with an ESPN row` = bbr_inactive_with_espn_row,
                           `Star with no ESPN row` = star_checked, `On BBR inactive list` = star_in_bbr_inactive)
  save_table(tA14, "tabA14_bbr_boxscore_check", "ESPN box-score rows against Basketball-Reference did-not-play and inactive lists, sample games",
             note = "One game per season, chosen so that a star has an ESPN no-row absence. BBR box scores list did-not-play and did-not-dress players inside the box and inactive players below it.")
  key("bbr_box_games", nrow(bb), "tabA14_bbr_boxscore_check"); key("bbr_box_dnp_match", paste0(sum(bb$espn_dnp_in_bbr_dnp), " of ", sum(bb$espn_dnp_rows)), "tabA14_bbr_boxscore_check")
  key("bbr_box_inactive_with_row", sum(bb$bbr_inactive_with_espn_row), "tabA14_bbr_boxscore_check"); key("bbr_box_stars_inactive", paste0(sum(bb$star_in_bbr_inactive), " of ", nrow(bb)), "tabA14_bbr_boxscore_check")
}

# Legacy-vs-clean table for the data appendix
diff_tab <- read_csv("results/tables/star_counts_orig_vs_clean.csv", show_col_types = FALSE) %>% filter(!season %in% COVID_SEASONS)
tA7 <- diff_tab %>% transmute(Season = season, Stars = n, `GP changed` = n_gp_changed, `QG changed` = n_qg_changed,
                              `Mean GP, raw` = f2(gp_orig, 1), `Mean GP, clean` = f2(gp_clean, 1), `Mean QG, raw` = f2(qg_orig, 1), `Mean QG, clean` = f2(qg_clean, 1),
                              `Crossed 65 only via exhibition` = crossed_65)
save_table(tA7, "tabA7_exhibition_correction", "Effect of removing All-Star and Rising Stars rows on star counts",
           note = "Games played also exclude the NBA Cup final (a non-regular-season game for statistics); qualifying games include it, as the rule does.")
key("exh_qg_changed_range_pre2024", paste(range(diff_tab$n_qg_changed[diff_tab$season <= 2024]), collapse = "-"), "tabA7_exhibition_correction")
key("exh_crossed_total", sum(diff_tab$crossed_65), "tabA7_exhibition_correction")


# -----------------------------------------------------------------------------
# 9. FIGURES
# -----------------------------------------------------------------------------
stage("STAGE 9: figures")
theme_paper <- theme_minimal(base_size = 11) + theme(panel.grid.minor = element_blank(), plot.title = element_blank(), plot.subtitle = element_blank())
save_fig <- function(p, name, w, h) {
  ggsave(file.path(OUT_F, paste0(name, ".png")), p, width = w, height = h, dpi = 300)
  write_rds(p, file.path(OUT_F, paste0(name, ".rds"))); cat("  wrote", name, "\n")
}
# Figure 1: policy timeline
timeline <- tribble(
  ~date,                  ~y,   ~hjust, ~label,
  as.Date("2017-09-28"),  1.2,  0.5, "Sept 2017: Player Resting Policy\n(no healthy rest on national TV;\nno resting multiple players)",
  as.Date("2019-11-11"),  -1.2, 1.0, "Nov 2019: memo bars 'load management'\nlabel for healthy players; Clippers\nfined $50,000 over Leonard statements  ",
  as.Date("2020-12-07"),  2.2,  0.5, "Dec 2020: memo reaffirms TV-game rule\n(fine at least $100,000) with COVID-season\ncarve-outs for non-televised games",
  as.Date("2023-04-26"),  1.2,  1.0, "Apr 2023: CBA ratified;\n65-game award-eligibility rule  ",
  as.Date("2023-09-13"),  -1.2, 0.0, "  Sept 2023: Player Participation Policy\n  (star definition, escalating fines,\n  no shutdowns; effective 2023-24)",
  as.Date("2024-04-10"),  1.1,  0.0, "  Apr 2024: league reports star\n  games missed down about 15%",
  as.Date("2026-04-16"),  -2.6, 1.0, "Apr 2026: two eligibility waivers\nat 63-64 games; one denial at 60  "
)
seasons_tl <- tibble(start = as.Date(c("2013-10-29", "2017-10-17", "2023-10-24")), end = as.Date(c("2017-04-12", "2023-04-09", "2026-04-12")),
                     regime = factor(c("Pre-2017 policy", "2017 resting policy", "PPP and 65-game rule"), levels = c("Pre-2017 policy", "2017 resting policy", "PPP and 65-game rule")))
p_tl <- ggplot() +
  geom_rect(data = seasons_tl, aes(xmin = start, xmax = end, ymin = -0.15, ymax = 0.15, fill = regime), alpha = 0.7) +
  geom_segment(data = timeline, aes(x = date, xend = date, y = 0, yend = y), colour = "grey40") +
  geom_point(data = timeline, aes(x = date, y = 0), size = 2.5) +
  geom_text(data = timeline, aes(x = date, y = y, label = label, hjust = hjust), size = 2.8, vjust = ifelse(timeline$y > 0, -0.1, 1.1), lineheight = 0.9) +
  scale_fill_manual(values = c("grey88", "grey72", "#e8c4c4")) +
  scale_x_date(limits = as.Date(c("2013-06-01", "2027-09-01")), date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(limits = c(-3.4, 3.6)) +
  labs(x = NULL, y = NULL, fill = NULL) +
  theme_minimal(base_size = 11) + theme(axis.text.y = element_blank(), panel.grid = element_blank(), legend.position = "bottom")
save_fig(p_tl, "fig1_policy_timeline", 9, 5)
save_fig(read_rds("results/figures/bunching_histogram.rds") + theme_paper, "fig2_bunching_histogram", 7.5, 6.5)
save_fig(read_rds("results/figures/es_availability.rds") + theme_paper, "fig3_availability_event_study", 7.5, 6.5)
save_fig(read_rds("results/figures/rest_by_state_bars.rds") + theme_paper + theme(legend.position = "bottom"), "fig4_absence_by_state", 7, 5)
save_fig(read_rds("results/figures/rest_by_state.rds") + theme_paper + theme(legend.position = "bottom"), "figA3_absence_by_state_by_season", 7.5, 5)
rs_figs <- read_rds("results/figures/rest_stars_vs_nonstars.rds")
p5 <- if (requireNamespace("patchwork", quietly = TRUE)) patchwork::wrap_plots(rs_figs$raw + theme_paper + theme(legend.position = "bottom"), rs_figs$es + theme_paper, ncol = 1) else rs_figs$es + theme_paper
save_fig(p5, "fig5_absence_stars_vs_nonstars", 7.5, 7.5)
for (f in c("fig1_bunching_histogram", "fig2_availability_event_study", "fig3_absence_by_state", "fig4_absence_stars_vs_nonstars")) for (ext in c(".png", ".rds")) unlink(file.path(OUT_F, paste0(f, ext)))
save_fig(read_rds("results/figures/at_risk_by_season.rds") + theme_paper, "figA1_at_risk_by_season", 7.5, 4.5)
save_fig(read_rds("results/figures/absence_timing.rds") + theme_paper + theme(legend.position = "bottom"), "figA2_absence_timing", 7.5, 6)


# -----------------------------------------------------------------------------
# 10. KEY NUMBERS FOR THE DRAFT
# -----------------------------------------------------------------------------
stage("STAGE 10: key numbers")
key_numbers <- bind_rows(keys)
write_csv(key_numbers, file.path(OUT_T, "key_numbers.csv"))
print(key_numbers, n = Inf)
check(nrow(key_numbers) > 60, "key-number sheet written")
cat("\nDone.\n")
