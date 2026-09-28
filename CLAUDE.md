# NBA 65-game rule: project instructions

## What this project is

An empirical economics paper evaluating the NBA's 65-game award-eligibility rule
(in force from the 2023-24 season) and the accompanying Player Participation
Policy (PPP). Working title: "A Bright Line That Binds on Few: The NBA's 65-Game
Rule and Star Availability."

The exploratory phase is done. The result is a set of precisely bounded nulls
plus a clear mechanism. Your job is to turn the exploratory analysis into a
reproducible pipeline, formal tables and figures, and a first draft. Read
`docs/exploratory_findings.md` before doing anything: it contains every result
so far, the code that produced each one, and the interpretation we settled on.

The PI is an assistant professor of data analytics and an applied
econometrician (DiD, event studies, fixest). Write for that reader. Do not
explain what a fixed effect is.

## The argument of the paper

1. The 65-game rule is a notch: award eligibility jumps from zero to full at
   65 qualifying games (>= 20 minutes, with up to two 15-19 minute games
   counting). The notch model predicts bunching at the threshold, slack-
   dependent play-through near it, and *more* rest once eligibility is either
   secured or unreachable.
2. None of that appears. No bunching; no change in reaching 65 among players
   near the line; no star-specific change in games played (pooled post x star
   -0.8, SE 2.3, MDE 6.5 games against the lagged control; 2024 alone -0.4,
   SE 3.0); no increase in absence in the secured or unreachable states. The
   raw 2024 star jump (59.4 -> 65.0) is half composition (entrants 69.6,
   leavers 46.7) and half a within-player rise (stayers +2.9) that sits inside
   the range of adjacent-season swings before the rule (fixed-cohort DiDs
   -3.6 to +4.2 pre-rule; 2023->2024 is +4.7, SE 3.4).
3. Mechanism: the notch binds on 10-15 player-seasons per season. Even if
   every one responded maximally, star mean games played would rise by about
   one game, inside the DiD interval. A bright line that binds on few cannot
   move a distribution of ~45.
4. Second mechanism: late-season absences by stars who played the previous
   game run 8-13% of player-games on the full schedule, with the same
   injury-driven gradient across eligibility states before and after the rule
   (unreachable stars absent about twice as often as reachable ones). The
   source cannot separate discretionary rest from new injury; absences coded
   rest or coach's decision are a lower bound of a few percent. No state shows
   a post-rule increase. (Reframed 2026-09-15; the earlier "1-3% rest" figure
   was an artifact of ESPN listing, see Data provenance.)
5. Neither the 2017 resting policy nor the 2023 PPP shows a star-specific
   change in healthy late-season absence; the post-rule star x season
   coefficients are inside +/- 0.02 with MDEs of about 0.05 on the full
   schedule. The raw rows-only 2018 drop tracks a fall in ESPN DNP-row
   coverage, not behavior.
6. Minutes: mixed, specification-dependent; do NOT call it the rule's
   detectable effect. With player FE the post x star coefficient on the share
   of appearances lasting 20+ minutes is 0.046 (SE 0.010), pre-period flat.
   Without player FE it is 0.027 (0.014), 0.020 (0.015) on 2022-2026, 0.021
   (0.019) with a star-specific trend, and the no-FE event study relative to
   2023 is 0.015, -0.006, 0.001. Raw DiD: 2.9 points against 2015-2023 but
   0.4 points against 2023 alone (star share already 0.976 in 2023; short
   appearances per star-season 3.2 in 2015-2022, 1.4 in 2023, 1.0 post).
   Never-switchers give the same split, so group switching is not the cause
   (results/tables/minutes_share20_specs.csv, reconciled 2026-09-17 after PI
   review). Report as consistent with a small lengthening of marginal
   appearances (the managed returns in Table 5d), not as a demonstrated
   effect. The tight-slack minute-bin pattern (H4) is nothing once returners
   are dropped.

The paper's contribution is bounds, not point estimates. Every null must be
reported with its minimum detectable effect next to it.

## Directory layout

```
data/raw            untouched pulls (hoopR rds, Basketball-Reference html). Do not modify.
data/raw/bbr        cached BBR pages. Do not re-request; ~30 pages already cached.
data/intermediate   cleaned single-source tables: player_box.rds, schedule.rds,
                    bbr_honors.rds, star_flags.rds
data/derived        analysis panels: player_season.rds/.csv (script 01, counts
                    include exhibition games; superseded for analysis by
                    player_season_clean.rds from script 02), plus every analysis
                    object built by scripts 02-06
assets              hand-coded lookups: name_overrides.csv, all_star_manual.csv
results/figures     figures (png, 200 dpi, plus the ggplot object as rds)
results/tables      tables (csv, plus LaTeX via modelsummary or kableExtra)
scripts             numbered scripts, run in order
docs                README.md, exploratory_findings.md, draft/
logs                run logs
```

`scripts/01_setup_and_pull.R` builds everything in data/intermediate and
data/derived/player_season.rds. It has already been run successfully. Do not
rerun it unless asked; do not change its outputs.

## Key definitions (use these exactly; they are in player_season.rds)

- Seasons are indexed by END year: 2016 = 2015-16. Sample 2014-2026.
- `covid`: seasons 2020, 2021. Always excluded from estimation.
- `post_rule`: seasons 2024, 2025, 2026.
- `star_ppp`: All-Star or All-NBA selection in any of the prior three seasons
  (the PPP's own definition of a star). Lagged, so never post-treatment.
  ~40-46 per season.
- `contender`: All-NBA, or any MVP/DPOY votes, in the prior season. ~20-31.
- `high_minute_nonstar`: not star_ppp, mpg >= 28, games_played >= 40 in the
  SAME season. This was the exploratory control. It conditions on the outcome:
  combined with the games_rostered >= 40 filter it truncates only the stars'
  low tail (long-injury seasons), and for absence outcomes it caps how many
  games a control player can miss. Kept for replication only.
- `hm_lag` (primary control from 2026-09-15): not star_ppp in season s, and
  mpg >= 28 with games_played >= 40 in season s-1 (clean counts). Defined
  before the outcome, like star_ppp. No filter on games_rostered. Undefined
  in 2014. `rot_lag`: same with mpg >= 20 (robustness, games played only; its
  qualifying-game count sits on the 20-minute margin and is not comparable).
  Both are partially treated (All-Defense, MIP, 6MOY are also subject to the
  rule); say so in the paper.
- `qualifying_games`: games with >= 20 min plus up to two games with 15-19
  min. Computed for every season for comparability.
- `played`: !did_not_play & minutes > 0. In the player-game panel a game
  with no ESPN row is `played = FALSE`, `has_row = FALSE`.
- `healthy` (player-game): played the team's previous game, on the full
  schedule. `healthy_rows` is the rows-only lag used in the exploratory work.
- `sat` = !played on the full schedule: absence, not rest. Rest and new
  injury cannot be separated in this source; say so wherever `sat` is used.
- `late_season`: team_game_no > 55.
- Eligibility `state` (player-game, computed from qualifying games so far and
  games remaining): secured (>= 65 already), reachable, unreachable.
- `slack`: qualifying games so far + games remaining - 65.

## Data provenance (for the data section)

- Player-game box scores: ESPN via hoopR `load_nba_player_box()`, seasons
  2014-2026, regular season only. KNOWN PROPERTY OF THE SOURCE: ESPN prints a
  row for an absent player only sometimes. DNP rows (which carry a reason
  string, 100% of the time) cover 29-40% of star absences in 2014-2017, 15%
  in 2018-2019, 7-10% in 2022-2024 and 10-16% in 2025-2026 (non-stars: 55%
  falling to 12-28%); the rest of the absences have no row at all
  (results/tables/dnp_row_coverage.csv). Any outcome computed on rows alone
  tracks ESPN's listing propensity. Absence must be measured on the full team
  schedule (data/derived/player_game_panel.rds, `has_row`, `absence_type`).
  MECHANISM (verified 2026-09-16 against 7 Basketball-Reference box scores,
  scripts/07_bbr_boxscore_check.R, results/tables/bbr_boxscore_check.csv):
  ESPN DNP rows are players on the ACTIVE list who did not play (BBR "Did Not
  Play"/"Did Not Dress"); players on the INACTIVE list have no ESPN row at all.
  So "no row" = inactive-list absence, and the coverage decline reflects how
  teams use the inactive designation, not ESPN printing behavior. Neither
  status maps to rest versus injury.
  ESPN also files the All-Star game and Rising Stars as regular-season games;
  script 02 removes them (data/derived/excluded_games.rds). The NBA Cup final
  is kept and flagged (cup_final): it does NOT count in regular-season
  statistics (games_played matches BBR without it) but DOES count toward the
  65-game rule (qualifying_games includes it; Wembanyama 2026 = 64 games, 65
  under the rule). data/derived/player_season_clean.rds carries both counts.
- Schedule and broadcast: hoopR `load_nba_schedule()`. Broadcast strings are
  empty before 2022; the national-TV flag is unusable before then, and the
  2017 resting policy already protected TV games, so the TV test is
  uninformative (see findings doc).
- All-NBA, All-Star, MVP/DPOY voting: Basketball-Reference, cached in
  data/raw/bbr. 2025 and 2026 All-Star rosters hand-entered from official
  selections (assets/all_star_manual.csv) because the game format changed.
- Name matching BBR -> ESPN via normalized keys; zero unmatched.

## Conventions

- R, tidyverse, fixest for estimation, modelsummary for regression tables,
  ggplot2 for figures. No Python.
- Every script: numbered, stages with headers, `check()` assertions between
  stages (copy the helper from 01_setup_and_pull.R), saves every analysis
  object to data/derived and every table/figure to results/.
- Cluster by athlete_id. Player-game regressions use athlete_id^season FE
  when treatment varies within player-season, and athlete_id + season FE
  when it varies at the player-season level (star x season interactions are
  collinear with athlete_id^season; this bit us once).
- Report MDEs: for each null, compute the minimum detectable effect at 80%
  power given the estimated SE, and put it in the table.
- Bunching: implement a standard excess-mass estimator with the pre-rule star
  distribution as the counterfactual density and bootstrap SEs. Report b with
  a CI.
- Do not scrape anything. Do not call stats.nba.com. Do not re-request
  Basketball-Reference. Everything needed is on disk.
- Do not overclaim. Where a result is suggestive (the H4 minutes pattern,
  the 2026 rest coefficient at p = 0.048), say suggestive. Where a test is
  underpowered by nature (at-risk reach rates, n = 3-15 per cell), say so
  and use the maximal-effect bound instead.
- Avoid the words "genuinely", "honestly", "straightforward", "robust" as
  adjectives. Plain declarative prose.

## What to build, in order

1. `scripts/02_build_panels.R`: from player_box.rds and player_season.rds,
   build and save (a) `game_idx` (team_game_no, team_games), (b) the
   player-game panel for stars and high-minute non-stars with q_sofar,
   remaining, slack, state, healthy, late_season, (c) the at-risk table
   (slack at team game 62). Save all to data/derived.
2. `scripts/03_availability.R`: games-played and qualifying-games DiD event
   studies (stars vs high-minute non-stars, ref 2023), with MDEs; bunching
   estimator with bootstrap; the at-risk reach-rate table with cell sizes.
   Save tables and figures.
3. `scripts/04_rest_behavior.R`: healthy late-season rest by eligibility
   state (pre/post and by season), the state x post_rule regression, the
   stars vs non-stars rest event study with ref 2023 and ref 2017. MDEs.
4. `scripts/05_minutes_and_injuries.R`: H4 minute-bin table with cell
   counts; a season-timing table of long absences (10+ consecutive missed
   games) for stars, pre vs post; both descriptive.
5. `scripts/06_tables_figures.R`: assemble the paper's tables (LaTeX) and
   figures from saved objects. Target: 5 tables, 4 figures.
   Added 2026-09-16: `scripts/07_bbr_boxscore_check.R` (BBR box-score check
   of the inactive-list mechanism; cached, do not extend without asking) and
   `scripts/08_draft_to_tex.R` (builds docs/draft/draft_v3.tex from the
   Markdown; compile with TinyTeX pdflatex, twice, from docs/draft). Edit the
   Markdown, never the .tex directly. `scripts/09_jse_to_tex.R` builds the
   Journal of Sports Economics submission version (APA 7 layout, 12-pt Times,
   double-spaced, endnotes, tables then figures, Appendix A as a separate
   supplement) from docs/draft/draft_v4_jse.md; it checks the 150-word abstract,
   4-5 keywords, citation/reference correspondence, and table/figure numbering.
6. `docs/draft/draft_v1.md`: a full first draft, ~6,000 words, sections:
   Introduction; The rule and a simple model; Data; Availability results;
   Rest behavior; Mechanisms; Discussion. Every number in the draft must
   come from a saved table; cite the file. No numbers from memory.

Run each script top to bottom after writing it and fix failures before
moving on. If a result differs materially from docs/exploratory_findings.md,
stop and report the discrepancy rather than proceeding; the findings doc
is the ground truth for what the data showed.
