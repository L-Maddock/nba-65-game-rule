# Exploratory findings: NBA 65-game rule

Ground truth for the paper. Every result below was produced interactively from
`data/intermediate/player_box.rds` and `data/derived/player_season.rds` after
the All-Star roster fix. The code that produced each result is included so it
can be rebuilt as scripts. Objects named here (`game_idx`, `at_risk`, `h8`,
`h4`, etc.) were NOT saved; rebuild and save them.

Conventions: seasons by end year; COVID seasons 2020, 2021 excluded; post-rule
= 2024-2026; `RULE_GAMES = 65`, `RULE_MIN = 20`, `RULE_MIN_LOW = 15`,
`RULE_LOW_ALLOW = 2`.

---

## 0. Sample

Star (PPP definition) and contender counts by season:

| season | stars | contenders |
|---|---|---|
| 2014 | 41 | 31 |
| 2015 | 44 | 30 |
| 2016 | 46 | 28 |
| 2017 | 43 | 26 |
| 2018 | 39 | 20 |
| 2019 | 38 | 26 |
| 2020 | 42 | 20 |
| 2021 | 44 | 22 |
| 2022 | 43 | 26 |
| 2023 | 45 | 25 |
| 2024 | 46 | 26 |
| 2025 | 46 | 24 |
| 2026 | 42 (before All-Star fix; rerun gives mid-40s) | 25 |

Star player-seasons: mean games played / mean qualifying games / share >= 65:

| season | n | gp | qg | share_ge65 |
|---|---|---|---|---|
| 2014 | 41 | 60.7 | 58.2 | 0.49 |
| 2015 | 43 | 63.5 | 61.1 | 0.65 |
| 2016 | 46 | 69.5 | 66.4 | 0.70 |
| 2017 | 40 | 70.8 | 66.7 | 0.65 |
| 2018 | 36 | 64.7 | 62.6 | 0.58 |
| 2019 | 37 | 63.6 | 61.9 | 0.68 |
| 2020 | 37 | 51.2 | 49.9 | 0.19 |
| 2021 | 41 | 55.0 | 54.4 | 0.24 |
| 2022 | 39 | 58.5 | 56.9 | 0.54 |
| 2023 | 45 | 59.7 | 58.8 | 0.47 |
| 2024 | 46 | 65.5 | 64.8 | 0.67 |
| 2025 | 46 | 63.1 | 62.0 | 0.54 |
| 2026 | 40 | 56.1 | 54.4 | 0.48 |

Note: the 2024 jump (59.7 -> 65.5) is league-wide, not star-specific (see DiD).

Box-score facts: 1230-1235 regular-season games per non-COVID season (1061,
1081 in 2020, 2021). DNP reason strings have 100% coverage in every season and
carry body-part detail ("SPRAINED LEFT ANKLE", "BACK SPASMS"). "REST" appears
only 410 times across 13 seasons; "COACH'S DECISION" is 58,057.

---

## 1. Bunching (H1): NULL

Stars, excluding COVID seasons, qualifying games:

| bin | n post | n pre | share post | share pre |
|---|---|---|---|---|
| <58 | 42 | 95 | 0.318 | 0.291 |
| 58-64 (below) | 15 | 38 | 0.114 | 0.116 |
| 65-68 (just above) | 14 | 37 | 0.106 | 0.113 |
| 69+ | 61 | 157 | 0.462 | 0.480 |

At one-game resolution the post-rule histogram shows 7 player-seasons at
exactly 65, 1 at 64, 2 at 66 (pre-rule: 10, 7, 10). Suggestive of mass *at*
the threshold (secure and sit), not above it; 7 vs 1 is not a result. Build
a formal excess-mass estimator with the pre-rule distribution as
counterfactual and bootstrap SEs.

Figure saved: results/figures/bunching_go_no_go.png. Table:
results/tables/bunching_go_no_go.csv.

---

## 2. At-risk reach rates (H2, crude): NULL, UNDERPOWERED

Stars with slack 0-8 at team game 62 (q_thru_62 + 20 - 65). Did they reach 65?

| contender | slack bin | n pre | n post | reached pre | reached post |
|---|---|---|---|---|---|
| FALSE | (-1,2] | 15 | 4 | 0.40 | 0.50 |
| FALSE | (2,5] | 13 | 8 | 0.69 | 0.75 |
| FALSE | (5,8] | 17 | 8 | 0.71 | 0.25 |
| TRUE | (-1,2] | 10 | 5 | 0.40 | 0.40 |
| TRUE | (2,5] | 15 | 3 | 0.53 | 0.33 |
| TRUE | (5,8] | 13 | 7 | 0.69 | 0.86 |

The at-risk population is 10-15 player-seasons per season. This is the
mechanism: the notch binds on very few. Improve the table by (a) conditioning
on healthy at game 62 (played 2 of the previous 3 games), (b) a current-season
contention proxy (top-30 in pts+reb+ast per game through game 62 among players
with 40+ games). Do not expect power; use it for the maximal-effect bound.

Code:
```r
game_idx <- player_box %>%
  distinct(season, team_id, game_id, game_date) %>%
  arrange(season, team_id, game_date) %>%
  group_by(season, team_id) %>% mutate(team_game_no = row_number(), team_games = n()) %>% ungroup()

at_risk <- player_box %>%
  inner_join(game_idx %>% select(game_id, team_id, team_game_no, team_games), by = c("game_id", "team_id")) %>%
  filter(team_game_no <= 62) %>%
  group_by(season, athlete_id) %>%
  summarise(q_thru_62 = sum(played & minutes >= RULE_MIN), .groups = "drop") %>%
  inner_join(player_season %>% select(season, athlete_id, qualifying_games, star_ppp, contender),
             by = c("season", "athlete_id")) %>%
  filter(star_ppp, !season %in% COVID_SEASONS) %>%
  mutate(slack_at_62 = q_thru_62 + 20 - RULE_GAMES, reached = qualifying_games >= RULE_GAMES)
```

---

## 3. Games-played DiD, stars vs high-minute non-stars (ref 2023): NULL, BOUNDED

Sample: !covid, star_ppp | high_minute_nonstar, games_rostered >= 40.
FE: athlete_id + season. Cluster: athlete_id.

games_played ~ i(season, star_ppp, ref = 2023):

| season | est | se |
|---|---|---|
| 2014 | -3.25 | 3.45 |
| 2015 | -0.87 | 2.87 |
| 2016 | -0.20 | 2.07 |
| 2017 | -1.23 | 2.13 |
| 2018 | -1.92 | 2.56 |
| 2019 | -1.12 | 2.64 |
| 2022 | -2.70 | 2.18 |
| 2024 | 1.12 | 2.07 |
| 2025 | -0.47 | 2.35 |
| 2026 | 2.07 | 2.65 |

qualifying_games version: 2024 0.98 (2.09), 2025 -1.23 (2.35), 2026 0.33 (2.52);
pre-period between -3.7 and +1.1.

Interpretation: 95% CI on the year-one effect roughly -3 to +5 games. Rules
out star-specific availability gains larger than ~5 games (~8% of the mean).
Report MDE at 80% power (~2.8 x SE ~= 6 games) in the table.

Caveat for the paper: high-minute non-stars are partially treated (All-
Defense, MIP, 6MOY). Run all-non-stars as a robustness control.

Code:
```r
did_df <- player_season %>%
  filter(!covid, star_ppp | high_minute_nonstar, games_rostered >= 40) %>%
  mutate(rel = factor(season, levels = setdiff(SEASONS, COVID_SEASONS)))
feols(games_played ~ i(rel, star_ppp, ref = "2023") | athlete_id + season, did_df, cluster = ~athlete_id)
```

---

## 4. Regime switch at 18th missed game (H3, first version): DISCARDED

The 18th non-qualifying game arrives inside an injury spell for most stars,
so a window around it measures return-from-injury timing, not a choice. The
regression produced coefficients near 1.0 on a binary outcome and ~16
effective clusters. Do not rebuild this version. The healthy-conditioned
version (section 5) replaces it.

---

## 5. Rest by eligibility state, healthy late-season stars (H8): GRADIENT CLOSES POST-2023, BUT SEE SECTION 7

Sample: stars, !covid, healthy (played previous game), team_game_no > 55.
Outcome `sat` = !played. State from qualifying games so far and games
remaining.

Cell sizes (pre / post): reachable 3380 / 1342; secured 1711 / 573;
unreachable 1363 / 459.

Rest rates:

| state | pre | post |
|---|---|---|
| reachable | 0.029 | 0.026 |
| secured | 0.058 | 0.021 |
| unreachable | 0.073 | 0.026 |

Regression `sat ~ i(state, post_rule, ref = "reachable") | athlete_id^season + team_game_no`:
secured x post -0.028 (0.009, p = 0.004); unreachable x post -0.115 (0.067, p = 0.09).

The notch model predicts MORE rest in secured/unreachable states post-rule.
The data show the opposite: the pre-rule gradient (no-incentive states rest
2-3x more) disappears. This is what the PPP (fines for resting all stars in
all states) predicts, not the notch. Note the outcome is any sit given
played last game, so rest-to-injury relabeling cannot affect it.

By-season event study of the gap (no_incentive = state != reachable), ref 2023,
FE athlete_id^season + team_game_no:

| season | est | se | p |
|---|---|---|---|
| 2014 | 0.034 | 0.023 | 0.15 |
| 2015 | -0.010 | 0.021 | 0.62 |
| 2016 | 0.041 | 0.024 | 0.08 |
| 2017 | 0.028 | 0.021 | 0.18 |
| 2018 | -0.027 | 0.011 | 0.02 |
| 2019 | -0.007 | 0.029 | 0.80 |
| 2022 | 0.018 | 0.037 | 0.64 |
| 2024 | -0.038 | 0.013 | 0.004 |
| 2025 | -0.011 | 0.019 | 0.57 |
| 2026 | -0.035 | 0.013 | 0.007 |

Not the play-in (2022 is +0.018). Closes in 2024 and 2026, not 2025. One
pre-year (2018) shows a move two-thirds as large. Moderate evidence.

Code:
```r
h8 <- player_box %>%
  inner_join(game_idx %>% select(game_id, team_id, team_game_no, team_games), by = c("game_id", "team_id")) %>%
  inner_join(player_season %>% select(season, athlete_id, star_ppp, contender), by = c("season", "athlete_id")) %>%
  filter(star_ppp, !covid) %>%
  arrange(season, athlete_id, team_game_no) %>%
  group_by(season, athlete_id) %>%
  mutate(qual = played & minutes >= RULE_MIN,
         q_sofar = lag(cumsum(qual), default = 0),
         remaining = team_games - team_game_no + 1,
         reachable = q_sofar + remaining >= RULE_GAMES,
         secured = q_sofar >= RULE_GAMES,
         healthy = lag(played, default = FALSE),
         late_season = team_game_no > 55) %>%
  ungroup() %>%
  filter(healthy, late_season) %>%
  mutate(state = case_when(secured ~ "secured", reachable ~ "reachable", TRUE ~ "unreachable"), sat = !played)
```

---

## 6. National-TV test: UNINFORMATIVE

Broadcast strings are empty before 2022 (share flagged national = 0 for
2014-2019; 0.27-0.33 for 2022-2026). Over 2022-2026: rest on non-TV games
0.048 -> 0.030, on TV games 0.023 -> 0.016; triple-difference 0.002 (0.010).
The 2017-18 resting policy already prohibited resting healthy players in
nationally televised games, so TV games were protected before the PPP and
the PPP's new provisions (no resting two stars, road-game availability, no
extended shutdowns) apply to all games. A uniform decline is what the policy
history predicts. Do not use this as a fingerprint of the PPP; mention it in
a footnote.

Broadcast strings seen: "NBA TV", "ESPN", "TNT", "ABC", "NBC/Peacock",
"Prime Video", "TNT/truTV/HBO Max", "ABC/ESPN+", "Peacock/NBCSN", etc.

---

## 7. Stars vs non-stars, healthy late-season rest: NO STAR-SPECIFIC CHANGE IN ANY REGIME

Raw rest rates (healthy, late_season), non-stars = high_minute_nonstar:

| season | non-star | star |
|---|---|---|
| 2014 | 0.030 | 0.071 |
| 2015 | 0.041 | 0.058 |
| 2016 | 0.037 | 0.068 |
| 2017 | 0.030 | 0.055 |
| 2018 | 0.024 | 0.028 |
| 2019 | 0.030 | 0.036 |
| 2022 | 0.027 | 0.032 |
| 2023 | 0.021 | 0.011 |
| 2024 | 0.032 | 0.017 |
| 2025 | 0.054 | 0.042 |
| 2026 | 0.036 | 0.014 |

Raw star rest halves in 2018 (the season after the Sept 2017 resting policy)
and is at its minimum in 2023, BEFORE the PPP and the 65-game rule.

Event study `sat ~ i(season, star_ppp, ref = X) | athlete_id + season + team_game_no`
(note: athlete_id + season, NOT athlete_id^season, which is collinear):

ref 2023: 2014 0.023 (0.014); 2015 0.009; 2016 0.023; 2017 0.018; 2018 -0.002;
2019 -0.001; 2022 0.012; 2024 -0.009 (0.008); 2025 -0.005; 2026 -0.021 (0.010, p = 0.048).

ref 2017: 2018 -0.007 (0.011, p = 0.54); 2023 -0.019 (0.009, p = 0.03);
2024 -0.014; 2025 -0.010; 2026 -0.025 (0.011, p = 0.02).

Interpretation: with player FE, the 2018 drop vanishes (composition: the
high-rest star-seasons of 2014-2017 belong to specific players who left the
star set). No star-specific change at 2017, 2023, or 2024 beyond a +/- 0.02
noise band. The section-5 gradient closing is a reshuffling inside a 1-3%
rest rate. Rest is a small margin; star absences are injury spells.

This section overrides the PPP interpretation in section 5. The paper's
claim is: neither the 2017 policy, the PPP, nor the threshold moved star
rest in a star-specific way, and the reason is that discretionary rest was
already 1-3% of late-season player-games.

---

## 8. Minutes floor (H4): SUGGESTIVE, SMALL N

Stars who played, team_game_no > 55. `tight` = slack 0-3, not yet secured.
Shares by minute bin (columns: post_rule_tight):

| bin | pre, not tight | pre, tight | post, not tight | post, tight |
|---|---|---|---|---|
| <15 | 0.018 | 0.008 | 0.008 | NA |
| 15-19 | 0.030 | 0.032 | 0.010 | 0.008 |
| 20-22 | 0.037 | 0.045 | 0.024 | 0.054 |
| 23-30 | 0.244 | 0.286 | 0.212 | 0.358 |
| 31+ | 0.671 | 0.629 | 0.746 | 0.579 |

Post-rule tight-slack stars shift from 31+ into 23-30 and 20-22 relative to
pre-rule tight-slack stars. Consistent with managed minutes to bank qualifying
games (the Haliburton pattern). Confounded by minute restrictions on players
returning from injury. Report cell counts; describe as consistent with the
mechanism, not as a finding.

---

## 9. Bounding argument (to formalize in the paper)

At-risk star-seasons (slack 0-8 at game 62) number ~10-15 per season. If
every one of them crossed 65 in response to the rule where they otherwise
would not, star mean games played would rise by at most ~1 game (15 players x
~3 extra games / 45 stars). That is inside the DiD interval. The rule cannot
have a detectable aggregate effect even under maximal compliance. Compute
this bound exactly from the at-risk table and report it.

---

## 10. Things that bit us (do not repeat)

- `player_box` already carries `covid` and `post_rule`; do not join them in
  again from `player_season` (creates .x/.y).
- `season` came out of the box score as integer; `game_date` in the schedule
  needs `as_date(ymd_hms(date))`.
- `athlete_id^season` FE absorb any star x season interaction. Use
  `athlete_id + season` for player-season-level treatment.
- The 18th-missed-game regime switch is inside injury spells; condition on
  healthy instead.
- Basketball-Reference All-Star pages for 2025 and 2026 do not parse; rosters
  are hand-entered in assets/all_star_manual.csv (selection counts, including
  injured selections and replacements).
