# A Bright Line That Binds on Few: The NBA's 65-Game Rule and Star Availability

*Draft v1, 2026-09-15. Every number below is taken from a saved table. Bracketed citations name files in `results/tables/paper/` unless a longer path is given; figures are in `results/figures/paper/`.*

## 1. Introduction

In the 2023-24 season the National Basketball Association (NBA) made a player's eligibility for its major individual awards conditional on playing at least 65 regular-season games. A game counts only if the player is on the floor for 20 minutes, with an allowance of two games between 15 and 19 minutes. The rule was one of two measures adopted together. The other, the Player Participation Policy (PPP), fines teams that rest healthy stars in nationally televised games, rest more than one star at a time, or shut down healthy players for long stretches. Both measures were aimed at the same complaint: that the league's best players sit out too many games, and that they do so by choice rather than because they are hurt.

The 65-game rule is a notch. Below the line a player receives nothing from the award system; at the line he receives full eligibility. Notches of this kind are studied throughout public economics because they generate sharp behavioral predictions: mass should pile up at the threshold, agents just short of it should push through, and agents who have either cleared it or fallen out of reach should relax. These predictions do not depend on the size of the prize, only on its being discontinuous. If stars were choosing to rest at the margin, the notch should leave a mark.

This paper looks for that mark and does not find it. Using every player-game from 2013-14 through 2025-26, we test each of the notch's predictions against the behavior of the roughly 40 to 46 players per season who meet the PPP's own definition of a star. There is no excess mass at 65 qualifying games. Stars who are within a few games of the line late in the season are no more likely to reach it after the rule than before. Star availability relative to comparable non-stars did not change in any of the three post-rule seasons, with a pooled difference-in-differences estimate of about one game and a minimum detectable effect of four. Late-season absence among stars who had played the previous game did not rise in the states where the rule removes the incentive to play. Each of these nulls is reported with the smallest effect the design could have detected, so that the reader can see what has and has not been ruled out.

The paper then explains why the nulls are what the arithmetic predicts. A threshold moves behavior only for agents for whom it is pivotal. In each season only about ten stars, a quarter of the group, are close enough to 65 late in the season for one or two more games to matter. Even if every one of them had responded fully, the mean number of qualifying games across all stars would have risen by between two-thirds of a game and 1.3 games, inside the confidence interval of the difference-in-differences estimate. A bright line that binds on few cannot move a distribution of forty-odd players by an amount that a season-level comparison could detect.

The second half of the explanation concerns the margin the rule was meant to reach. Absences by stars are dominated by injury spells, not single nights off. In the pooled pre-rule seasons a third of star player-seasons contain a spell of ten or more consecutive missed games, and those spells account for ten missed games per star-season. Among late-season absences that follow a game the star played, the box-score source used here attributes a reason to fewer than half before the rule and to under a fifth after it, so discretionary rest cannot be separated from new injury. What can be said is that the absence rate of stars who had just played shows the same gradient across eligibility states before and after the rule, with no state rising, and that stars and high-minute non-stars moved together at both the 2017 resting policy and the 2023 rule.

The paper contributes to the literature on notches and bunching by documenting a case in which a clean notch produced no detectable response and by tracing the null to the small size of the population at the margin. It also contributes a data result of independent use to researchers working with ESPN box scores: the source prints a row for an absent player only some of the time, and the share of absences that receive a row fell from around 30 to 40 percent in 2014-2017 to under 10 percent by 2023. Outcomes computed from rows alone track this listing behavior rather than player behavior.

Section 2 describes the rule and sets out the predictions of a simple model. Section 3 describes the data and the construction of the panel. Section 4 reports the availability results: the difference-in-differences event studies, the bunching estimator, and the at-risk reach rates. Section 5 reports absence behavior. Section 6 formalizes the two mechanisms. Section 7 discusses what the results mean for the policy and for the study of notches.

## 2. The rule and a simple model

### 2.1 The rule

The 65-game rule was ratified in the 2023 collective bargaining agreement and applied from the 2023-24 season. To be eligible for Most Valuable Player, Defensive Player of the Year, Most Improved Player, Sixth Man of the Year, the All-NBA teams, and the All-Defensive teams, a player must appear in at least 65 regular-season games. A game counts if the player plays at least 20 minutes. Up to two games of 15 to 19 minutes also count. There are exceptions for season-ending injuries after 62 qualifying games and for a small set of other circumstances that do not bear on the analysis.

The stakes attached to eligibility are large for a minority of players. All-NBA selection triggers salary escalators and eligibility for the largest contract tiers under the collective bargaining agreement, and several current contracts contain bonuses conditional on award selection. For the median star the stakes are smaller: an All-NBA third team is a distinction rather than a payday, and Sixth Man or Most Improved is out of reach for a player already recognized as a star.

The PPP took effect in the same season. It requires teams to manage the rest of stars, defined as players who made an All-Star or All-NBA team in any of the prior three seasons, so that healthy stars are available for nationally televised and in-season tournament games, are not rested together, are not held out of road games in preference to home games, and are not shut down for long stretches while healthy. Teams face escalating fines for violations. The PPP does not act on the player's incentives; it acts on the team's.

A resting policy adopted in September 2017 already prohibited resting healthy players in nationally televised games and discouraged resting several players at once. That policy is the earlier of the two breaks examined in Section 5.

### 2.2 A model of the notch

Consider a star deciding, game by game, whether to play. Let $q$ be the number of qualifying games played so far, $r$ the number of games remaining, and $\bar q = 65$ the threshold. Each game played yields a flow benefit $b$ and carries a cost $c_g$ that varies with fatigue, minor injury, and schedule. Award eligibility is worth $V \geq 0$ and is received if and only if $q \geq \bar q$ at season's end. Before the rule $V$ enters continuously through voters' impressions; after the rule it enters as a step.

Three predictions follow. First, a player who reaches exactly 65 has no further eligibility motive to play, so mass should collect at the threshold and thin just above it, relative to the pre-rule distribution. Second, define slack as $q + r - \bar q$, the number of remaining games a player can miss and still reach the line. For players with small non-negative slack late in the season, the option value of eligibility raises the return to playing through a marginal cost, so the share reaching 65 should rise after the rule, and rise most among players for whom $V$ is largest. Third, once slack is negative (the line is unreachable) or $q \geq \bar q$ (eligibility is secured), the marginal eligibility incentive is zero. Relative to the reachable state, absence in these two states should rise after the rule, because the pre-rule continuous incentive to impress voters has been replaced by nothing.

The PPP pushes against the third prediction. Its fines are levied on teams for resting healthy stars in any state, so it predicts a uniform fall in discretionary rest across states. The two policies therefore have opposite implications for the state gradient and the same implication for aggregate star availability. Section 5 reports both.

The model also says where to look. The rule can change the behavior only of players whose counterfactual season would have ended near 65. A player who would have played 75 games regardless is unaffected; so is a player whose injury ends the season at 40. The at-risk population is those with small slack late in the season, and the aggregate effect of the rule is bounded by the number of such players multiplied by the games each could add. Section 6 computes that bound.

## 3. Data

### 3.1 Sources

Player-game box scores come from ESPN through the hoopR package, for regular seasons 2013-14 through 2025-26. Seasons are indexed by end year throughout, so 2024 denotes 2023-24. The 2019-20 and 2020-21 seasons, which were shortened and played under pandemic conditions, are kept in the raw data and excluded from every estimate. The schedule, including broadcast strings, comes from the same source. Award and honor lists (All-NBA, All-Star, and MVP and Defensive Player of the Year voting) come from Basketball-Reference pages cached once; the 2025 and 2026 All-Star rosters were entered by hand because the game's format changed and the pages no longer parse. Names were matched between the two sources through normalized keys with no unmatched honorees.

### 3.2 Definitions

A star in season $s$ is a player who made an All-Star or All-NBA team in any of seasons $s-3$ to $s-1$. This is the PPP's own definition, and because it is lagged it cannot respond to the treatment. There are between 36 and 46 stars per season with at least one appearance [tab1_sample]. A contender is a star who made an All-NBA team or received an MVP or Defensive Player of the Year vote in the prior season. The primary control group is high-minute non-stars: players who are not stars, average at least 28 minutes per game, and play at least 40 games. They number 69 to 96 per season [tab1_sample]. This group is partially treated, since All-Defensive, Most Improved, and Sixth Man awards are also subject to the rule, and a robustness control of rotation players (20 or more minutes per game, 40 or more games) is reported alongside.

Qualifying games are computed for every season under the rule's definition: games of 20 or more minutes plus up to two games of 15 to 19 minutes. A player-game is *played* if the player logged positive minutes. Slack, eligibility state, and the health condition are defined at the player-game level as in Section 2, with state computed from qualifying games before the game and games remaining including it. The late-season window is team game 56 onward. A player is *healthy* entering a game if he played his team's previous game.

### 3.3 Two properties of the source

Two features of the ESPN box scores required correction and shape what can be measured.

First, ESPN files the All-Star game, the Rising Stars games, and, from 2024, the NBA Cup final as regular-season games. Because stars play in these games, raw season totals overstate their games played and qualifying games. Removing these rows lowers qualifying games by one for ten to seventeen stars per season through 2024 and for three or four in 2025 and 2026, when the All-Star formats kept minutes under 20 [tabA7_exhibition_correction]. Three star-seasons cross 65 only because of an exhibition game. All counts in the paper exclude these rows. A check of ten star-seasons against Basketball-Reference finds all nine with a reference value matching exactly; the tenth, Kawhi Leonard in 2022, played no games and has no ESPN row, so he is absent from the sample [tabA5_bbr_validation]. Fourteen flagged star-seasons outside the pandemic years have no appearance; most are retired players still flagged from earlier honors, and the rest missed the whole season [tabA6_stars_no_appearance].

Second, and more consequentially, ESPN prints a box-score line for a player who did not play only some of the time. Those lines, called DNP rows here, carry a reason string with body-part detail. Most absences have no line at all. Table 2 [tab2_source_coverage] reports, for every season, the share of absences that received a DNP row. For stars it was 28 to 40 percent in 2014 through 2017, 15 percent in 2018 and 2019, 7 to 10 percent in 2022 through 2024, and 8 to 16 percent in the post-rule seasons. For high-minute non-stars it fell from 55 percent in 2014 to between 12 and 28 percent from 2022 on. The total absence rate of stars did not fall over the period; it was between 14 and 32 percent of team-games in every season. Absences moved from rows to no rows.

The consequence is that any outcome computed from rows alone measures ESPN's listing practice rather than player behavior. We therefore build the player-game panel on the full schedule of each player's team stint: every game of the team between the player's first and last appearance, extended to the start of the season for his first team and to the end for his last. A game with no row is an absence with unknown reason. A flag records whether a row exists, so that the rows-only construction can be reproduced; those replications appear in the appendix and match earlier exploratory work.

The same property limits what can be learned about rest. Among late-season absences by stars who had played the previous game, 45 percent had a DNP row before the rule and 19 percent after it [rest_absence_reason_bounds.csv]. Of the reasons that are given, "rest" and "coach's decision" account for a quarter of all such absences before the rule and 2.6 percent after; the remainder are injury and illness strings or no row at all [tabA4_absence_reasons]. Because the no-row absences cannot be classified, discretionary rest and new injury cannot be separated in this source. Section 5 measures absence, says so, and reports what the reasons say where they exist.

### 3.4 The sample

Table 1 [tab1_sample] describes the sample. Stars averaged 59.4 games played in 2023 and 65.0 in 2024, a rise of more than five games; the share with at least 65 qualifying games went from 0.44 to 0.67. Both fell back in 2025 and 2026, to 62.4 and 54.8 games and to 0.54 and 0.45. Section 4 shows that the 2024 rise was not specific to stars.

## 4. Availability results

### 4.1 Difference-in-differences event studies

Figure 2 and Table 3 [tab3a_availability_event_study] report event-study estimates of star availability relative to high-minute non-stars, with 2023 as the reference season. The specification regresses games played, or qualifying games, on star-by-season indicators with player and season fixed effects, clustering by player, on players with at least 40 rostered games. The sample is 1,194 player-seasons of 274 players [tab3b_availability_pooled].

The post-rule coefficients for games played are 1.07 (SE 2.04) in 2024, -0.51 (2.31) in 2025, and 1.26 (2.52) in 2026. The corresponding minimum detectable effects at 80 percent power are 5.7, 6.5, and 7.1 games. Pre-period coefficients lie between -3.69 and -0.37 and none is distinguishable from zero. Qualifying games behave the same way: 1.04 (2.06), -0.88 (2.33), and 0.66 (2.50) in the three post-rule seasons. The 2024 rise in star games played visible in Table 1 is matched in the control group, whose mean games played moved from 70.1 to 68.9 as stars moved from 59.4 to 65.0; the star-specific component is the one-game coefficient.

Pooling the post-rule seasons [tab3b_availability_pooled], the star-specific change in games played is 1.05 (SE 1.41), with a 95 percent confidence interval from -1.72 to 3.82 games and a minimum detectable effect of 4.0 games. For qualifying games it is 0.92 (1.42), interval -1.86 to 3.70. The share of player-seasons at or above 65 rises by 0.062 (0.064), with a minimum detectable effect of 0.18. Against the rotation-player control the pooled estimates are 0.81 (1.31) for games played and 1.40 (1.46) for qualifying games, and no pre-period coefficient of that event study is significant at 5 percent. A control of all non-stars with 40 rostered games fails the pre-trend test, because 2023 is a trough in deep-bench minutes, and is not used.

The event studies rule out a star-specific increase in availability larger than about four games in the pooled comparison and about six to seven games in any single season. They do not rule out an increase of one or two games. Section 6 shows that one or two games is the most the rule could have produced.

### 4.2 Bunching at 65

Figure 1 plots the distribution of qualifying games for star player-seasons before and after the rule, with the pre-rule distribution overlaid on the post-rule panel as the counterfactual. Table 4a [tab4a_bunching_bins] gives the mass in four bins. The share of star-seasons in the bin just below the threshold, 58 to 64 games, is 0.122 before and 0.121 after. The share just above, 65 to 68, is 0.125 before and 0.106 after. The share under 58 rises from 0.291 to 0.318, and the share at 69 or more falls from 0.462 to 0.455.

Table 4b [tab4b_bunching_excess_mass] reports an excess-mass estimator. The counterfactual is the pre-rule distribution of stars' qualifying games, 327 player-seasons, scaled to the 132 post-rule player-seasons. For a window above the threshold, $b$ is the excess count divided by the mean counterfactual mass per one-game bin in that window; $m$ is the analogous statistic for the window below. Confidence intervals come from 2,000 bootstrap resamples of both distributions.

At exactly 65 games there are 6 post-rule star-seasons against a counterfactual of 3.6, for $b$ = 0.65 with a 95 percent interval from -0.59 to 3.95. Widening the window to 65 and 66 games gives 6 observed against 8.9 expected, $b$ = -0.65 [-1.59, 0.97]; widening to 65 through 68 gives 14 against 16.6, $b$ = -0.62 [-2.28, 1.83]. The missing-mass statistics below the threshold are likewise centered near zero. No window rejects zero excess mass. Using only 2022 and 2023 as the counterfactual, the estimates turn negative: with the 65-to-68 window, $b$ = -2.22 [-3.15, -0.73], because those two seasons happened to place unusual mass just above 65. There is no configuration in which post-rule stars are more concentrated at or above the line than pre-rule stars.

The six post-rule seasons at exactly 65 against one at 64 are consistent with a few players securing eligibility and stopping. They are also consistent with chance, and the interval says so.

### 4.3 At-risk stars

The bunching test uses whole-season outcomes. A more direct test conditions on being near the line with games left to play. At team game 62, with twenty games remaining, a star with slack between 0 and 8 can still reach 65 but cannot miss many more games. Table 5a [tab5a_at_risk_reach] reports, for stars who were also healthy at game 62 (played at least two of games 60 to 62), whether they finished with 65 qualifying games.

The cells are small. Post-rule there are 2 healthy at-risk stars with slack 0 to 2, 9 with slack 3 to 5, and 11 with slack 6 to 8. The reach rates in those bins are 1.00, 0.56, and 0.64 against pre-rule rates of 0.40, 0.70, and 0.60 from 20, 27, and 25 star-seasons. Fisher exact tests give p-values of 0.19, 0.44, and 1.00. A linear probability model pooling the bins [tab5b_at_risk_regressions] gives a post-rule change in the reach probability of 0.02 (SE 0.13) among healthy at-risk stars, with a minimum detectable effect of 0.36; adding a control for current-season contention (top 30 in points, rebounds, and assists per game through game 62) gives 0.10 (0.13). Across all at-risk stars, healthy or not, the estimate is -0.07 (0.10).

These tests are underpowered by construction. Only 22 healthy at-risk stars exist in three post-rule seasons. The design cannot detect a change in the reach probability smaller than about a third. The table is reported for what it shows, which is the size of the population at the margin, and Section 6 uses it for that purpose rather than for inference about behavior.

## 5. Rest behavior

### 5.1 What is measured

The outcome in this section is absence: a star did not play a late-season game after having played his team's previous game. On the full schedule this rate runs between 7.9 and 13.1 percent of star player-games across seasons, and between 3.3 and 12.0 percent for high-minute non-stars [rest_raw_by_season.csv]. These rates include players who were injured in the game they had just played and players who chose to sit. As Section 3.3 explained, the source attributes a reason to a minority of these absences, and among the absences with reasons, injury strings outnumber rest strings. Nothing in this section should be read as a rest rate. It is an absence rate for players who were, as far as the schedule shows, available the night before.

The earlier exploratory construction, which counted only games with an ESPN row, produced star rest rates of 7.1 percent in 2014 and 1.1 percent in 2023 [rest_raw_by_season_rowsonly.csv]. That fall coincides with the fall in row coverage in Table 2 and is not evidence about behavior. The rows-only estimates are reproduced in Appendix Table A1 for comparison.

### 5.2 Absence by eligibility state

Table 6a [tab6a_absence_by_state] and Figure 3 report absence by eligibility state. Before the rule, healthy late-season stars were absent from 7.1 percent of games in the reachable state, 10.8 percent when eligibility was already secured, and 14.6 percent when 65 was out of reach. After the rule the three rates are 9.2, 12.2, and 16.1 percent. The changes are 2.1 (SE 0.9), 1.3 (1.5), and 1.4 (2.0) percentage points, with the largest change in the state where the rule leaves the incentive to play intact.

The gradient across states is present in both periods and is what an injury process produces without any incentive: players who have missed enough games to fall out of reach are players who are hurt, and they keep missing games. The notch model predicts that the gradient should steepen after the rule, as the secured and unreachable states lose their remaining incentive. It does not. The PPP predicts a uniform fall. There is none.

Table 6b [tab6b_absence_state_regressions] puts these comparisons in a regression with player-season and team-game-number fixed effects, so that the state-by-post interactions are identified from players who move between states within a late season. The secured-by-post coefficient is -0.008 (SE 0.019) and the unreachable-by-post coefficient is 0.008 (0.137). Collapsing the two no-incentive states gives -0.003 (0.019). The minimum detectable effects are 0.054 for the secured and collapsed interactions and 0.385 for the unreachable interaction, which is identified from few within-season transitions. The unreachable main effect is -0.139 (0.042), a reminder that within a player-season the arrival of the unreachable state coincides with the return from an injury spell rather than with a decision to rest.

The design can detect a post-rule rise in secured-state absence of about five percentage points, roughly half the pre-rule rate. It detects none.

### 5.3 Stars against non-stars at two policy breaks

Table 6c [tab6c_absence_star_vs_nonstar] and Figure 4 compare stars with high-minute non-stars. The event study regresses absence on star-by-season indicators with player, season, and team-game-number fixed effects. The post-rule coefficients, relative to 2023, are -0.014 (SE 0.017) in 2024, -0.017 (0.022) in 2025, and -0.009 (0.021) in 2026, with minimum detectable effects of 0.048, 0.063, and 0.059 [tabA1_absence_event_study]. The pooled post-rule-by-star coefficient is -0.020 (0.014) across 2014 to 2026 and -0.023 (0.014) across 2022 to 2026, with minimum detectable effects of 0.039. For the September 2017 resting policy, the post-2017-by-star coefficient over 2014 to 2019 is 0.009 (0.015), minimum detectable effect 0.042.

Neither policy produced a detectable star-specific change in late-season absence. The pre-period is not flat: the 2014 coefficient is 0.046 (0.019), and 2019 and 2022 sit at 0.031 and 0.036, so stars were absent relatively more often than non-stars in several early seasons than in 2023. With 2017 as the reference the pattern is the same. The design can detect star-specific changes of about four to six percentage points against a base of eight to thirteen percent. Changes smaller than that are not ruled out.

### 5.4 Nationally televised games

Broadcast strings are empty in the source before 2022, so a test of the PPP's national-television provision can use only 2022 and 2023 as the pre-period. Over that window, absence by healthy late-season stars in non-televised games went from 12.4 to 13.5 percent and in televised games from 11.2 to 7.2 percent [rest_tv_rates.csv]; the triple difference with player-season and game-number fixed effects is -0.022 (0.021) [rest_tv_ddd.csv]. The 2017 policy already protected televised games, so the comparison is between two regimes that both did so and is not informative about the PPP.

## 6. Mechanisms

### 6.1 The notch binds on few

The number of stars for whom the rule could have changed a season is small. Table 5c [tab5c_bound] and Appendix Figure A1 count, in each season, the stars with slack between 0 and 8 at team game 62. There are between 5 and 18 such stars per season, an average of 10.2 before the rule and 11.7 after, or a quarter of all stars [at_risk_bound_by_season.csv; tab5c_bound]. Of those, an average of 4.5 per season before the rule and 5.7 after finished short of 65.

Two bounds follow. Under minimal crossing, every at-risk star who fell short instead plays exactly enough additional qualifying games to reach 65. Summing those games and dividing by the number of stars gives the most the rule could have added to mean star qualifying games under this response: 0.67 games per star-season in the pre-rule seasons, that is, the counterfactual gain had the rule applied then, and 0.98 in the post-rule seasons. Under the more extreme assumption that every at-risk star plays every remaining game, the bound is 1.27 games pre-rule and 1.83 post-rule. The upper limit of the pooled qualifying-games confidence interval in Table 3b is 3.70 games. Both bounds lie inside it.

The arithmetic is general. A notch changes the behavior of agents whose counterfactual outcome lies within their choice range of the threshold. When that set is a quarter of the population and each member can move by at most a handful of games, the aggregate effect is at most one or two games out of sixty, and a season-level comparison with standard errors of two games cannot see it. The event studies of Section 4 are not a failure of the design; they are the design telling us what the population at the margin already implied.

### 6.2 Star absences are spells

The second mechanism concerns what star absences consist of. Appendix Table A3 [tabA3_long_absences] describes spells of ten or more consecutive missed games. Before the rule there were 127 such spells in 327 star-seasons, or 0.39 per star-season, and 33 percent of star-seasons contained one. After the rule there were 65 in 132 star-seasons, 0.49 per star-season, with 39 percent of star-seasons affected. The mean spell lasted 25.6 games before the rule and 22.2 after. Long spells alone account for 10.0 missed games per star-season before the rule and 11.0 after, out of a total absence rate that Table 2 puts between 14 and 32 percent of an 82-game schedule.

Where the source gives a reason for a spell, it is an injury or illness in 30 percent of pre-rule spells and 20 percent of post-rule spells; a further 56 and 77 percent have no row at any point in the spell and therefore no reason. Spells that begin with a rest or coach's-decision string are 11 percent of pre-rule spells and none of the post-rule spells. About a third of spells are still running at the season's end. The timing of spell onsets is spread across the season, with 21 percent beginning in the late-season window before the rule and 31 percent after.

A policy that addresses single nights off does not reach this margin. The rule and the PPP can, in principle, change whether a healthy star sits out the second night of a back-to-back. They cannot change whether a star tears a ligament in February. Because absences of the second kind dominate the first by an order of magnitude, the aggregate availability of stars is determined mostly by something the policies do not touch.

### 6.3 A suggestive trace: managed minutes

One pattern is consistent with the notch model and is reported as such. Appendix Table A2 [tabA2_minute_bins] tabulates the minutes played by late-season stars by whether they were tight, meaning slack of 0 to 3 with eligibility not yet secured. Among tight stars after the rule, 34.5 percent of player-games fell in the 23-to-30-minute bin and 4.1 percent in the 20-to-22 bin, against 29.4 and 4.2 percent for tight stars before the rule and 21.4 and 2.6 percent for post-rule stars who were not tight. The share of tight stars' games at 31 or more minutes fell from 62.3 to 60.5 percent. The post-rule tight cell contains 220 player-games from 18 players.

This is what a player banking qualifying games on managed minutes would produce. It is also what a minute restriction on a player returning from injury would produce, and players returning from injury are over-represented among the tight. Restricting to stars who had played each of the previous three games, the 23-to-30 share among post-rule tight stars is 30.5 percent against 29.5 percent before the rule, a difference of one point from 46 player-games. The pattern is suggestive and no more.

## 7. Discussion

### 7.1 What the results show

The 65-game rule was designed as a bright line, and bright lines are supposed to move behavior at the margin. Across every test the notch model suggests, the line left no detectable mark on the availability of the players it was written for. There is no excess mass at 65. The stars nearest the line were no more likely to cross it. Star availability moved with the availability of comparable players, not away from it. Absence among stars who had just played did not rise in the states where the rule removed the incentive to play, and did not fall in the state where it preserved it.

The reason is not that stars ignored the rule. It is that the rule could only matter to the quarter of stars within reach of the line in the season's final weeks, and that even a complete response by all of them would have added at most a game or two to the mean. The rest of star absence is injury, and injury is indifferent to award eligibility.

The 2023-24 season did see stars play more: 65.0 games against 59.4 the season before. The comparison group rose by less and the difference between them is one game with a standard error of two. Stars then played fewer games in each of the next two seasons. Whatever raised availability in 2024, it did not persist and was not concentrated among the players subject to the rule.

### 7.2 What the results do not show

The design bounds effects; it does not estimate them precisely. A star-specific gain of one to three games per season is inside every confidence interval reported here and is also the size of gain the bounding argument allows. Readers who believe the rule changed a handful of seasons at the margin will find nothing in this paper that contradicts them, and the six player-seasons finishing at exactly 65 are a plausible trace of that. What the paper rules out is an effect large enough to matter for the complaint that motivated the rule.

The absence results are bounded more loosely than the availability results and rest on an outcome that the source cannot decompose. A post-rule change in discretionary rest among stars smaller than four to six percentage points of late-season games would not be detected here, and a change that was offset by a change in injury absence of the opposite sign would not be visible at all. The reason strings that exist say that rest was a quarter of attributable late-season absences before the rule and a few percent after, but the attributable share itself fell from 45 to 19 percent, so the two periods are not comparable on this dimension. Establishing what happened to discretionary rest requires an injury report or a transaction log with complete coverage, which this source is not.

The control group is partially treated. High-minute non-stars include the candidates for All-Defensive, Most Improved, and Sixth Man honors, all subject to the same 65-game requirement. If those players responded to the rule, the difference-in-differences estimates are biased toward zero. The rotation-player control dilutes that exposure and gives the same answer, and the bounding argument does not depend on a control group at all.

Three post-rule seasons is a short window, and the most recent of them may still be subject to revision in the source. The rule's stakes could also grow: as more contracts write bonuses against All-NBA selection, $V$ rises for more players, and the set for whom the threshold is pivotal could widen. Nothing here speaks to that future.

### 7.3 Implications

For the league, the results say that award eligibility is the wrong lever for the availability problem as it exists. The players whose absences drive the aggregate are injured, and the players who are healthy and choosing are few and already playing most nights. A rule that binds on ten players a season, each of whom can add a few games, has a ceiling of about one game per star, and that ceiling is below the noise in a season's schedule. Policies that reduce injury exposure, such as schedule density, would act on the larger margin; whether they can is a separate question.

For the study of notches, the case is a useful negative. The literature on bunching has grown around settings where the population near the threshold is large relative to the population as a whole, so that the excess mass is visible in a histogram and the elasticity can be recovered from it. Here the notch is clean, the prize is real, and the population is small. The absence of visible bunching is not evidence of a zero elasticity. It is evidence that the estimator has nothing to work with. Reporting the size of the at-risk population and the bound it implies, alongside the null, is the appropriate way to present such a case, and we suggest it as a routine step in notch studies where the threshold is far from the mass of the distribution.

For researchers using ESPN box scores through hoopR or similar tools, Table 2 is the practical result. The source does not record absences; it records some of them, and the share it records has changed over time and differs between stars and other players. Any panel built from box-score rows should be rebuilt on the schedule before absence, rest, or availability is measured.

---

### Tables and figures

Main text: Table 1 `tab1_sample`; Table 2 `tab2_source_coverage`; Table 3 `tab3a_availability_event_study`, `tab3b_availability_pooled`; Table 4 `tab4a_bunching_bins`, `tab4b_bunching_excess_mass`; Table 5 `tab5a_at_risk_reach`, `tab5b_at_risk_regressions`, `tab5c_bound`; Table 6 `tab6a_absence_by_state`, `tab6b_absence_state_regressions`, `tab6c_absence_star_vs_nonstar`. Figures 1-4: `fig1_bunching_histogram`, `fig2_availability_event_study`, `fig3_absence_by_state`, `fig4_absence_stars_vs_nonstars`.

Appendix: Tables A1-A7 (`tabA1_absence_event_study`, `tabA2_minute_bins`, `tabA3_long_absences`, `tabA4_absence_reasons`, `tabA5_bbr_validation`, `tabA6_stars_no_appearance`, `tabA7_exhibition_correction`); Figures A1-A2 (`figA1_at_risk_by_season`, `figA2_absence_timing`). Every table exists as `.tex` (booktabs) and `.md`.
