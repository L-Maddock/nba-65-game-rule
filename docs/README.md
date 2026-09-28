# Notching, the NBA's 65-Game Rule, and Star Player Availability

Replication materials for a paper evaluating the NBA's 65-game award-eligibility
rule (in force from the 2023-24 season) and the Player Participation Policy
adopted alongside it. The paper treats the rule as a notch, tests each of the
behavioral predictions that framework generates on every player-game from
2013-14 through 2025-26, and reports bounded nulls: no excess mass at 65
qualifying games, no change in the share of stars near the line who cross it,
and no star-specific change in games played relative to a control group defined
on prior-season status. It then shows why. Half of the rise in star games played
that the league cited after the rule's first season was a change in which
players were stars; only a quarter to two-fifths of stars are within reach of
the threshold late in a season; and star absence is dominated by injury spells
the rule does not touch.

Author: Luke Maddock, Department of Data Analytics, Denison University
(maddockl@denison.edu). Status: manuscript under preparation for submission to
the *Journal of Sports Economics*. A citation will be added on acceptance.

## Repository layout

| Path | Contents |
|---|---|
| `scripts/` | Numbered R scripts; run in order (see below) |
| `assets/` | Hand-coded lookups: `all_star_manual.csv` (2025 and 2026 All-Star selections, entered by hand because the game format changed), `name_overrides.csv` (Basketball-Reference to ESPN name matches), `stakes_manual.csv` (award-linked contract terms for the case table, from press reporting), `bbr_validation_manual.csv` (box-score checks) |
| `data/intermediate/` | Cleaned single-source tables: schedule, honors, star flags |
| `data/derived/` | Analysis panels and saved model objects: `player_season.csv`, `player_game_panel.rds`, `at_risk.csv`, `long_absences.csv`, and others |
| `results/tables/` | Every table produced by the analysis scripts (CSV); `results/tables/paper/` holds the manuscript tables as `.tex` and `.md` |
| `results/figures/` | Figures as PNG plus the ggplot objects as RDS; `results/figures/paper/` holds the manuscript figures |
| `docs/` | Manuscript drafts (`docs/draft/`), the exploratory findings log, and this README |
| `CLAUDE.md` | Project instructions and definitions used during development |

Not tracked in the repository, and rebuilt by the scripts:

- `data/raw/`: the ESPN box-score and schedule pulls from hoopR (large and
  re-downloadable) and cached Basketball-Reference pages (not redistributed)
- `data/intermediate/player_box.rds` (54 MB) and `data/derived/rest_models.rds`
  (66 MB): rebuilt by scripts 01 and 04
- `logs/`

## Reproducing the analysis

Requirements: R (4.x), with `tidyverse`, `lubridate`, `janitor`, `hoopR`,
`rvest`, `stringi`, `fixest`, and `modelsummary`. Set `PROJECT_ROOT` at the top
of `scripts/01_setup_pull.R` to the repository path.

Run the scripts in order:

1. `01_setup_pull.R` builds the directory tree, downloads player box scores and
   schedules for 2013-14 through 2025-26 through hoopR (no live scraping of
   ESPN; the data come from the sportsdataverse releases), fetches about thirty
   Basketball-Reference pages at a six-second delay and caches them, matches
   names, builds the lagged star flags, and writes `data/derived/player_season.rds`.
2. `02_build_panels.R` removes exhibition rows (All-Star, Rising Stars), builds
   the full-schedule player-game panel with slack, eligibility state, and health
   flags, and constructs the at-risk tables.
3. `03_availability.R` estimates the availability event studies and pooled
   difference-in-differences, the bunching estimator with bootstrap intervals,
   and the maximal-effect bound.
4. `04_rest_behavior.R` estimates late-season absence by eligibility state and
   the star-versus-control absence event studies.
5. `05_minutes_and_injuries.R` produces the minute-bin tables, the 20-minute
   share event studies, and the long-absence (spell) tables.
6. `06_tables_figures.R` assembles the manuscript tables and figures into
   `results/tables/paper/` and `results/figures/paper/`.
7. `07_bbr_boxscore_check.R` verifies the ESPN active-list property against a
   sample of Basketball-Reference box scores.
8. `08_draft_to_tex.R` and `09_jse_to_tex.R` convert the Markdown drafts to
   LaTeX.

Each script ends its stages with `check()` assertions that stop on failure.
Scripts 01 through 05 take a few minutes each; the bunching bootstrap in 03 is
the slowest step. The first run of 01 needs network access; subsequent runs use
the cached pulls.

## Key definitions

- Seasons are indexed by end year: 2016 denotes 2015-16. The 2019-20 and
  2020-21 seasons (2020 and 2021) are retained in the raw data and excluded from
  every estimate; the paper's Data section explains why.
- A **star** in season *s* is a player selected to an All-Star or All-NBA team
  in any of seasons *s*-3 to *s*-1, the Player Participation Policy's own
  definition. The **control group** is players who are not stars in season *s*
  and who averaged at least 28 minutes per game with at least 40 games in
  season *s*-1.
- **Qualifying games** follow the rule: games of 20 or more minutes, plus up to
  two games of 15 to 19 minutes, including the in-season tournament final.
  **Games played** is the regular-season statistic and excludes the final.
- **Slack** is qualifying games so far plus games remaining minus 65. A player
  is **at risk** with slack of 0 to 8 at team game 62, and **healthy** entering
  a game if he played his team's previous game. The late-season window is team
  game 56 onward.
- An ESPN box score carries only players on the active list. Absences are
  therefore measured on the full team schedule, with a flag for whether a
  box-score row exists. Outcomes computed from rows alone track roster
  designation, not behavior.

## Data sources

Player-game box scores and schedules: ESPN, accessed through the hoopR package
(Gilani, 2021). Honors: Basketball-Reference. Policy dates, rule text, and
contract stakes: cited in the manuscript. All sources are publicly available;
raw pulls are not redistributed here and are rebuilt by the scripts.

## License

Code is released under the MIT License. Derived data tables inherit the terms
of their sources.
