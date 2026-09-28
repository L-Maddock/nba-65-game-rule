# A Bright Line That Binds on Few: The NBA's 65-Game Rule and Star Availability

*Draft v2, 2026-09-15. Every number below is taken from a saved table. Bracketed citations name files in `results/tables/paper/` unless a longer path is given; figures are in `results/figures/paper/`. Changes from v1 are listed at the end.*

## 1. Introduction

In the 2023-24 season the National Basketball Association (NBA) made a player's eligibility for its major individual awards conditional on playing at least 65 regular-season games. A game counts only if the player is on the floor for 20 minutes, with an allowance of two games between 15 and 19 minutes. The rule was one of two measures adopted together. The other, the Player Participation Policy (PPP), fines teams that rest healthy stars in nationally televised games, rest more than one star at a time, or shut down healthy players for long stretches. Both were aimed at the same complaint, voiced by the commissioner at the time as load management having "gotten away from us a bit" (NBA.com 2023): that the league's best players sit out too many games, and that they do so by choice rather than because they are hurt.

The 65-game rule is a notch in the sense of Kleven and Waseem (2013). Below the line a player receives nothing from the award system; at the line he receives full eligibility. Notches generate sharp predictions: mass should pile up at the threshold, agents just short of it should push through, and agents who have either cleared it or fallen out of reach should relax. The direction of these predictions does not depend on the size of the prize; the magnitude does, which is why Section 7 counts the players for whom the prize is large and pivotal. Where the population near a threshold is thin or the prize small, the bunching literature has long recognized that no visible response should be expected (Saez 2010; Chetty et al. 2011; Kleven 2016).

This paper tests each of the notch's predictions against the behavior of the roughly 40 to 46 players per season who meet the PPP's own definition of a star, using every player-game from 2013-14 through 2025-26. It finds no mark. There is no excess mass at 65 qualifying games. Stars within a few games of the line late in the season are no more likely to reach it after the rule than before. Star availability relative to comparable players defined on prior-season status did not change in any post-rule season; the pooled difference-in-differences estimate for games played is -0.8 games with a standard error of 2.3, and the smallest effect the design could have detected is 6.5 games. Late-season absence among stars who had played the previous game did not rise in the states where the rule removes the incentive to play. Each null is reported with its minimum detectable effect.

The raw numbers that circulated after the rule's first season read differently, and the paper explains why. Stars averaged 59.4 games in 2023 and 65.0 in 2024, a rise of 5.6 games that the league cited as evidence the policy was working (Sportico 2024). Half of that rise is a change in who the stars were: the seven players who entered the star set in 2024 averaged 69.6 games and the six who left had averaged 46.7 in 2023. The other half, a rise of 2.9 games among the 39 players who were stars in both seasons, is a year-to-year swing of the size seen several times before the rule. A fixed-cohort comparison of 2023 with 2024 gives 4.7 games with a standard error of 3.4; the same comparison gave 4.2 games from 2015 to 2016 and -5.2 from 2025 to 2026.

The paper then explains why the nulls are what the arithmetic predicts. In each season only about ten stars, a quarter of the group, are close enough to 65 late in the season for one or two more games to matter. Even if every one had responded fully, mean qualifying games across all stars would have risen by between two-thirds of a game and 1.3 games, inside the confidence interval of every estimate reported. A bright line that binds on few cannot move a distribution of forty-odd players by an amount that a season-level comparison could detect.

The second half of the explanation concerns the margin the rule was meant to reach. Absences by stars are dominated by spells, not single nights off. A third of star player-seasons contain a spell of ten or more consecutive missed games, and those spells account for ten missed games per star-season. Among late-season absences that follow a game the star played, the box-score source used here attributes a reason to fewer than half before the rule and to under a fifth after it, so discretionary rest cannot be separated from new injury. What can be said is that absence among stars who had just played shows the same gradient across eligibility states before and after the rule, with the only significant change a rise in the state where the rule preserves the incentive to play, and that stars and non-stars moved together at both the 2017 resting policy and the 2023 rule.

The paper makes three contributions. To our knowledge it is the first econometric evaluation of the 65-game rule or the PPP; the closest academic work studies the performance effects of rest by age and cites the policy only as motivation (arXiv 2402.12400), and the league's own figures are descriptive press claims (Sportico 2024, 2025). To the literature on notches it adds a case in which a clean notch with real stakes produced no detectable response, and traces the null to the small size of the population at the margin rather than to a zero elasticity, in the spirit of the frictions interpretation in Saez (2010) and Chetty et al. (2011). To researchers working with ESPN box scores it documents that the source prints a row for an absent player only some of the time, and that the share of absences receiving a row fell from around 30 to 40 percent in 2014-2017 to under 10 percent by 2023; outcomes computed from rows alone track this listing behavior.

Section 2 reviews the rule, the policies around it, and the literatures the paper draws on. Section 3 sets out a simple model. Section 4 describes the data. Sections 5 and 6 report availability and absence results. Section 7 formalizes the two mechanisms. Section 8 discusses what the results do and do not show.

## 2. Background

### 2.1 The rule and the policies around it

The 65-game rule was ratified in the 2023 collective bargaining agreement and applied from the 2023-24 season. To be eligible for Most Valuable Player, Defensive Player of the Year, Most Improved Player, Sixth Man of the Year, the All-NBA teams, and the All-Defensive teams, a player must appear in at least 65 regular-season games of at least 20 minutes, with up to two games of 15 to 19 minutes also counting. Rookie of the Year is exempt (ESPN 2023b). There is an exception for season-ending injuries after 62 qualifying games and a provision for extraordinary circumstances. In April 2026 the league and the union jointly ruled two players eligible under that provision, one with 64 qualifying games who missed two games for the birth of a child and one with 63 after a collapsed lung, while a third, with 60, took his case to an arbitrator and lost (ESPN 2026; Forbes 2026). Our own counts for those three players are 64, 63, and 60 [waiver_cases_2026.csv], which is a useful check on the qualifying-game construction. The waivers also mean the notch is not quite as sharp as the rule reads, a point Section 8 returns to.

The stakes attached to eligibility are large for a minority of players. All-NBA selection triggers salary escalators and eligibility for the largest contract tiers, and several contracts carry bonuses conditional on selection. One player's exclusion from the 2023 All-NBA teams was reported to have cost him roughly 39 million dollars over five seasons (Sportico 2023). For the median star the stakes are smaller: an All-NBA third team is a distinction rather than a payday, and Sixth Man or Most Improved is not a realistic target for a player already recognized as a star.

The PPP took effect in the same season. It defines a star as a player selected to an All-Star or All-NBA team in any of the prior three seasons, requires teams to keep healthy stars available for nationally televised and in-season tournament games, forbids resting two stars in the same game, requires a balance of home and road absences, bars long shutdowns of healthy players, and imposes fines of 100,000 dollars for a first violation, 250,000 for a second, and one million more than the previous penalty thereafter (NBA 2023; ESPN 2023a). The PPP acts on the team, not the player.

A resting policy adopted in September 2017 already prohibited resting healthy players in nationally televised games and resting multiple players at once. The PPP's contribution was the formal star definition, the escalating fines, the roster-balancing and no-shutdown provisions, and league enforcement, not the television or multi-player prohibitions themselves (ESPN 2023b). The 2017 policy is the earlier of the two breaks examined in Section 6.

### 2.2 Notches, bunching, and thresholds in sport

The empirical study of notches descends from Saez (2010), who compared the observed density of taxable income around kink points with a smooth counterfactual and recovered elasticities from the excess mass. His headline result is itself a set of nulls: clear bunching at only one kink, and only among the self-employed. Chetty et al. (2011) showed that optimization frictions attenuate bunching and that kinks affecting larger groups produce larger observed responses. Kleven and Waseem (2013) extended the method to notches, where the discontinuity is in the level rather than the slope, and showed that notches create dominated regions in which no agent should locate and that large shares of agents nonetheless remain there, which identifies the size of frictions. Kleven (2016) surveys the method and states the interpretive caveat that governs this paper: absence of bunching implies either a low structural elasticity or high frictions, and the data around the threshold alone cannot separate them. Bertanha, McCallum, and Seegert (2023) provide identification and inference for bunching and notching estimators, including the partially identified case, which is the appropriate frame for the bounds reported here.

Thresholds in sport have produced some of the clearest bunching evidence outside tax data. Pope and Simonsohn (2011) show that batters entering their final at-bat of a season at .298 or .299 hit .463 in that at-bat, and Allen et al. (2017) find finishing times piling up just under round numbers in nine and a half million marathon results. Both settings share two features the 65-game rule lacks: the threshold sits near the center of the outcome distribution, and the marginal action is cheap and available to everyone near the line. A games-played threshold sits in the upper tail of a distribution shaped mostly by injury, and the marginal action, playing an additional game, is unavailable to an injured player.

### 2.3 Awards and tournaments as incentives

The rule conditions access to a rank-order tournament. Lazear and Rosen (1981) showed that effort in such tournaments responds to the spread between prizes, and Ehrenberg and Bognanno (1990) confirmed the prediction on the professional golf tour. Awards without money attached also move behavior: Kosfeld and Neckermann (2011) found that purely symbolic awards raised performance in a field experiment, Neckermann, Cueni, and Frey (2014) found the same for workplace awards, and Chan et al. (2014) for academic honors. Frey and Gallus (2017) treat awards as a distinct incentive instrument. These results justify treating All-NBA and All-Defensive selection as incentives even where no bonus is written into a contract. They also make the null here more informative: the prize is one that the literature says people respond to.

### 2.4 Strategic responses in sports labor markets

Kahn (2000) made the case for sports data as a laboratory for labor-market hypotheses, and a literature has tested whether NBA players respond to individual financial incentives. Stiroh (2007) found that performance rises in the season before a new contract and falls after it; Berri and Krautmann (2006) tested for shirking under guaranteed pay; White and Sheldon (2014) compared contract-year effects across the NBA and Major League Baseball; and a recent study reports statistically insignificant contract-year changes across advanced metrics (Applied Economics Letters 2026). Krautmann and Donley (2009) revisit shirking in baseball. Teams respond to bright-line league rules too: Taylor and Trogdon (2002) and Price et al. (2010) show that teams lose more often when the draft rewards losing. Fumarco et al. (2024) document strategic responses to contractual thresholds in the National Hockey League, and Kessock (2016) reviews service-time manipulation in baseball, where teams manage a games threshold against a player's interest; a 2024 case in which a player was released four plate appearances short of a bonus is the mirror image of the individual incentive studied here (CBS Sports 2024). The 65-game rule differs from these settings in that the threshold is written into a league rule rather than a contract, applies to a named class of players, and interacts with an injury process that the player does not control.

### 2.5 Why star availability matters, and what drives it

Rosen (1981) explained why a few performers capture a disproportionate share of a market's value. Hausman and Leonard (1997) estimated the value of one star to the other teams in the league at about 53 million dollars through television ratings, road attendance, and merchandise. Kaplan (2022), using secondary-market ticket data and absence announcements, found that a superstar's announced absence reduces ticket prices by 4 to 22 percent, and by more for road games; Kaplan et al. (2019) is the conference precursor. The externality these papers measure is what the PPP is designed to internalize.

On the supply side, the sports-medicine literature ties absences to schedule and injury rather than choice. Teramoto et al. (2017) found that back-to-back and road games predicted game injuries over three seasons, though Mack et al. (2018) note that the study described exposures rather than risks. Esteves et al. (2021) show that schedule congestion degrades performance. Season-level counts put NBA injuries above 800 per season, concentrated in the middle and late season (PLOS ONE 2022). League figures released in 2025 reported games missed to injury up 13 percent in 2024-25 and stars missing 19 percent of games to injury in each of the two post-rule seasons, the same as in 2017-18 and 2018-19 (Sportico 2025). These are press figures, not estimates, but they set the scale: injury absence is an order of magnitude larger than anything a rest policy could reach.

### 2.6 Competing work

A search of SSRN, NBER, arXiv, the MIT Sloan Sports Analytics Conference, and Google Scholar returned no article, working paper, or thesis that evaluates the 65-game rule or the PPP as its research question. The nearest item, arXiv 2402.12400, estimates age-conditioned effects of rest on performance and cites the policy as motivation. The remaining coverage is journalism, and the league's own claims about the rule's effect, a 15 percent fall in games missed by stars and a fall in back-to-backs with a star resting from 88 to 77 (Sportico 2024), are descriptive. Section 5.1 shows what those raw comparisons consist of.

## 3. A simple model

Consider a star deciding, game by game, whether to play. Let $q$ be the number of qualifying games played so far, $r$ the number of games remaining, and $\bar q = 65$ the threshold. Each game played yields a flow benefit $b$ and carries a cost $c_g$ that varies with fatigue, minor injury, and schedule. Award eligibility is worth $V \geq 0$ and is received if and only if $q \geq \bar q$ at season's end. Before the rule $V$ enters continuously through voters' impressions; after the rule it enters as a step.

Three predictions follow. First, a player who reaches exactly 65 has no further eligibility motive to play, so mass should collect at the threshold and thin just above it, relative to the pre-rule distribution. Second, define slack as $q + r - \bar q$, the number of remaining games a player can miss and still reach the line. For players with small non-negative slack late in the season, the option value of eligibility raises the return to playing through a marginal cost, so the share reaching 65 should rise after the rule, and rise most among players for whom $V$ is largest. Third, once slack is negative or $q \geq \bar q$, the marginal eligibility incentive is zero. Relative to the reachable state, absence in these two states should rise after the rule, because the continuous pre-rule incentive has been replaced by nothing.

The magnitude of every prediction scales with $V$ and with the number of players for whom the threshold is pivotal. A player who would have played 75 games regardless is unaffected; so is a player whose injury ends the season at 40. The at-risk population is those with small slack late in the season, and the aggregate effect of the rule is bounded by the number of such players multiplied by the games each could add. Section 7 computes that bound.

The PPP pushes against the third prediction. Its fines are levied on teams for resting healthy stars in any state, so it predicts a uniform fall in discretionary absence across states. The two policies therefore have opposite implications for the state gradient and the same implication for aggregate availability.

## 4. Data

### 4.1 Sources

Player-game box scores come from ESPN through the hoopR package (Gilani 2021), for regular seasons 2013-14 through 2025-26. Seasons are indexed by end year, so 2024 denotes 2023-24. The 2019-20 and 2020-21 seasons are kept in the raw data and excluded from every estimate. The schedule, with broadcast strings, comes from the same source. Award and honor lists come from Basketball-Reference pages cached once; the 2025 and 2026 All-Star rosters were entered by hand because the game's format changed. Names were matched between the two sources through normalized keys with no unmatched honorees. Estimation uses fixest (Bergé 2018).

### 4.2 Definitions

A star in season $s$ is a player who made an All-Star or All-NBA team in any of seasons $s-3$ to $s-1$. This is the PPP's own definition, and because it is lagged it cannot respond to the treatment. There are between 36 and 46 stars per season with at least one appearance [tab1_sample]. A contender is a star who made an All-NBA team or received an MVP or Defensive Player of the Year vote in the prior season.

The primary control group is defined the same way, on prior-season status: players who are not stars in season $s$ and who in season $s-1$ averaged at least 28 minutes per game and played at least 40 games. They number 68 to 90 per season from 2015 on; none can be defined for 2014 [tab1_sample]. A robustness control uses rotation players, 20 or more minutes per game and 40 or more games in the prior season. Defining the control on the prior season matters. An earlier version of this analysis defined it on the current season's minutes and games played, which selects the control group on the outcome: a control player cannot have missed more than 42 games, while a star can have missed 80. Combined with a filter on rostered games, that design truncated the stars' low tail and produced narrower but biased comparisons. The current-season design is retained in the tables as a comparison row and labeled exploratory. Both controls are partially treated, since All-Defensive, Most Improved, and Sixth Man awards carry the same 65-game requirement.

Qualifying games are computed for every season under the rule's definition. A player-game is *played* if the player logged positive minutes. Slack, eligibility state, and the health condition are defined at the player-game level as in Section 3. The late-season window is team game 56 onward. A player is *healthy* entering a game if he played his team's previous game.

### 4.3 Two properties of the source

Two features of the ESPN box scores required correction and shape what can be measured. The first is minor. ESPN files the All-Star game, the Rising Stars games, and, from 2024, the NBA Cup final as regular-season games. Removing these rows lowers qualifying games by one for ten to seventeen stars per season through 2024 and for three or four in 2025 and 2026, and three star-seasons cross 65 only because of an exhibition game [tabA7_exhibition_correction]. All counts exclude these rows. A check of ten star-seasons against Basketball-Reference finds all nine with a reference value matching exactly; the tenth played no games and has no ESPN row [tabA5_bbr_validation]. Fourteen flagged star-seasons outside the pandemic years have no appearance, most of them retired players still flagged from earlier honors [tabA6_stars_no_appearance].

The second property is consequential. ESPN prints a box-score line for a player who did not play only some of the time. Those lines, called DNP rows here, carry a reason string. Most absences have no line at all. Table 2 [tab2_source_coverage] reports the share of absences that received a DNP row. For stars it was 28 to 40 percent in 2014 through 2017, 15 percent in 2018 and 2019, 7 to 10 percent in 2022 through 2024, and 8 to 16 percent in the post-rule seasons. For the control group it fell from 30 to 38 percent in 2015-2017 to between 9 and 23 percent from 2022 on. The total absence rate of stars did not fall over the period; it was between 14 and 32 percent of team-games in every season. Absences moved from rows to no rows.

Any outcome computed from rows alone therefore measures ESPN's listing practice. The player-game panel is built instead on the full schedule of each player's team stint: every game of the team between the player's first and last appearance, extended to the start of the season for his first team and to the end for his last. A game with no row is an absence with unknown reason. A flag records whether a row exists so that the rows-only construction can be reproduced; those replications appear in the appendix.

The same property limits what can be learned about rest. Among late-season absences by stars who had played the previous game, 45 percent had a DNP row before the rule and 19 percent after it [rest_absence_reason_bounds.csv]. Of the reasons given, "rest" and "coach's decision" account for a quarter of all such absences before the rule and 2.6 percent after; the remainder are injury and illness strings or no row at all [tabA4_absence_reasons]. Discretionary rest and new injury cannot be separated in this source. Section 6 measures absence, says so, and reports what the reasons say where they exist.

### 4.4 The sample

Table 1 [tab1_sample] describes the sample. Stars averaged 59.4 games played in 2023 and 65.0 in 2024; the share with at least 65 qualifying games went from 0.44 to 0.67. Both fell back in 2025 and 2026, to 62.4 and 54.8 games and to 0.54 and 0.45. The control group averaged 65.6 games in 2023, 66.1 in 2024, 62.0 in 2025, and 58.8 in 2026.

## 5. Availability results

### 5.1 Difference-in-differences event studies

Figure 2 and Table 3a [tab3a_availability_event_study] report event-study estimates of star availability relative to the control group, with 2023 as the reference season. The specification regresses games played, or qualifying games, on star-by-season indicators with player and season fixed effects, on all star and control player-seasons from 2015 to 2026 with no filter on the outcome. Standard errors are clustered by player throughout, following Bertrand, Duflo, and Mullainathan (2004). Every null in the paper is accompanied by its minimum detectable effect, defined once here as the effect that would be detected with 80 percent power in a two-sided 5 percent test given the estimated standard error, which is 2.80 times that standard error. The sample is 1,093 player-seasons of 255 players [tab3b_availability_pooled].

The post-rule coefficients for games played are -0.41 (SE 2.95) in 2024, -0.20 (3.00) in 2025, and -2.87 (4.48) in 2026, with minimum detectable effects of 8.3, 8.4, and 12.6 games. Pre-period coefficients lie between -5.30 and 3.28 and none is distinguishable from zero. Qualifying games give 2.07 (3.14), 1.99 (3.10), and -0.13 (4.58). Pooling the post-rule seasons [tab3b_availability_pooled], the star-specific change in games played is -0.81 (SE 2.33), with a 95 percent confidence interval from -5.37 to 3.75 games and a minimum detectable effect of 6.5 games. For qualifying games it is 1.72 (2.44), with an upper limit of 6.50. The share of player-seasons at or above 65 rises by 0.056 (0.069), minimum detectable effect 0.19.

The rotation control gives 2.47 (2.14) for games played, but 6.80 (2.30) for qualifying games, and its 2017 coefficient is also positive and significant at 5.10 (2.27). The qualifying-games result is not read as a rule effect. A rotation player's qualifying count sits on the 20-minute margin: the group's ratio of qualifying games to games played is 0.64 to 0.73 across seasons against 0.97 to 0.99 for stars [qg_gp_ratio_by_group.csv], so qualifying games for that group measure minutes per game rather than appearances, and the rule did not change how many games they played relative to stars. The exploratory design, with the current-season control and the rostered-games filter, gives 1.05 (1.41) pooled and 1.07 (2.04) for 2024; its narrower intervals come from truncating the stars' low tail and are shown for comparison only.

### 5.2 What happened in 2024

Table 1 shows stars playing 5.6 more games in 2024 than in 2023 while the control group played 0.6 more. Table A8 [tabA8_composition_2024] decomposes the star change. The 39 players who were stars in both seasons went from 61.3 to 64.2 games, a rise of 2.9. The seven players who entered the star set in 2024 averaged 69.6 games; the six who left had averaged 46.7 in 2023. Half of the raw rise is therefore a change in who the stars were, and half is a within-player rise. Among control stayers, games played fell by 3.8.

The within-player half is not unusual. Table A9 [tabA9_cohort_pairs] estimates a fixed-cohort difference-in-differences for every pair of adjacent seasons, with groups fixed at their status in the first season and players present in both. The 2023 to 2024 estimate is 4.66 (SE 3.44, p = 0.18). The five pre-rule pairs range from -3.59 to 4.15; 2024 to 2025 gives 3.91 and 2025 to 2026 gives -5.16. The rule's first season produced the largest adjacent-season swing in the series, by half a game, and the swing reversed in the next two seasons. The multi-season event study, which uses all seasons to estimate each player's level, puts 2024 at -0.41 (2.95). The raw jump the league cited was partly a different set of stars and partly a one-season movement of the size the series produces on its own.

### 5.3 Bunching at 65

Figure 1 plots the distribution of qualifying games for star player-seasons before and after the rule, with the pre-rule distribution overlaid on the post-rule panel as the counterfactual, following the counterfactual-density logic of Saez (2010) and Kleven and Waseem (2013). Table 4a [tab4a_bunching_bins] gives the mass in four bins. The share of star-seasons in the bin just below the threshold, 58 to 64 games, is 0.122 before and 0.121 after. The share just above, 65 to 68, is 0.125 before and 0.106 after.

Table 4b [tab4b_bunching_excess_mass] reports an excess-mass estimator. The counterfactual is the pre-rule distribution of stars' qualifying games, 327 player-seasons, scaled to the 132 post-rule player-seasons. For a window above the threshold, $b$ is the excess count divided by the mean counterfactual mass per one-game bin in that window; $m$ is the analogous statistic below. Confidence intervals come from 2,000 bootstrap resamples of both distributions. At exactly 65 games there are 6 post-rule star-seasons against a counterfactual of 3.6, for $b$ = 0.65 with a 95 percent interval from -0.59 to 3.95. Widening to 65 and 66 gives 6 observed against 8.9 expected, $b$ = -0.65 [-1.59, 0.97]; widening to 65 through 68 gives 14 against 16.6, $b$ = -0.62 [-2.28, 1.83]. No window rejects zero excess mass. Using only 2022 and 2023 as the counterfactual, the estimates turn negative, with $b$ = -2.22 [-3.15, -0.73] for the widest window, because those two seasons placed unusual mass just above 65.

The six post-rule seasons at exactly 65 are consistent with a few players securing eligibility and stopping; two of the 2026 seasons at 64 belong to players who were then granted eligibility by waiver. They are also consistent with chance, and the interval says so.

### 5.4 At-risk stars

At team game 62, with twenty games remaining, a star with slack between 0 and 8 can still reach 65 but cannot miss many more games. Table 5a [tab5a_at_risk_reach] reports, for stars who were also healthy at game 62, whether they finished with 65 qualifying games. Post-rule there are 2 healthy at-risk stars with slack 0 to 2, 9 with slack 3 to 5, and 11 with slack 6 to 8. The reach rates are 1.00, 0.56, and 0.64 against pre-rule rates of 0.40, 0.70, and 0.60 from 20, 27, and 25 star-seasons. Fisher exact tests give p-values of 0.19, 0.44, and 1.00. A linear probability model pooling the bins [tab5b_at_risk_regressions] gives a post-rule change of 0.02 (SE 0.13) among healthy at-risk stars, minimum detectable effect 0.36; adding a control for current-season contention gives 0.10 (0.13).

These tests are underpowered by construction. Only 22 healthy at-risk stars exist in three post-rule seasons. The table is reported for what it shows, which is the size of the population at the margin, and Section 7 uses it for that purpose.

## 6. Absence behavior

### 6.1 What is measured

The outcome in this section is absence: a player did not play a late-season game after having played his team's previous game. On the full schedule this rate runs between 7.9 and 13.1 percent of star player-games across seasons, and between 5.9 and 12.5 percent for the control group [rest_raw_by_season.csv]. These rates include players injured in the game they had just played and players who chose to sit. As Section 4.3 explained, the source attributes a reason to a minority of these absences, and among those with reasons, injury strings outnumber rest strings. Nothing in this section should be read as a rest rate. It is an absence rate for players who were, as far as the schedule shows, available the night before. The design can detect changes of four to seven percentage points in that rate; changes in discretionary rest smaller than that, or offset by changes in injury absence, are not visible here.

The earlier rows-only construction produced star rest rates of 7.1 percent in 2014 and 1.1 percent in 2023 [rest_raw_by_season_rowsonly.csv]. That fall coincides with the fall in row coverage in Table 2 and is not evidence about behavior.

### 6.2 Absence by eligibility state

Table 6a [tab6a_absence_by_state] and Figure 3 report absence by eligibility state. Before the rule, healthy late-season stars were absent from 7.1 percent of games in the reachable state, 10.8 percent when eligibility was already secured, and 14.6 percent when 65 was out of reach. After the rule the three rates are 9.2, 12.2, and 16.1 percent. The changes are 2.1 (SE 0.9), 1.3 (1.5), and 1.4 (2.0) percentage points. The one change that is distinguishable from zero is the rise in the reachable state, where the notch predicts a fall, not a rise. The secured and unreachable states, where the notch predicts a rise, show changes no larger than the reachable state's and not distinguishable from zero.

The gradient across states is present in both periods and is what an injury process produces without any incentive: players who have missed enough games to fall out of reach are players who are hurt, and they keep missing games. Table 6b [tab6b_absence_state_regressions] puts the comparisons in a regression with player-season and team-game-number fixed effects, so that the state-by-post interactions are identified from players who move between states within a late season. The secured-by-post coefficient is -0.008 (SE 0.019), with a minimum detectable effect of 0.054; the collapsed no-incentive interaction is -0.003 (0.019). The unreachable-by-post interaction is 0.008 with a standard error of 0.137, because few players move into the unreachable state within the late-season window; that coefficient is uninformative and the descriptive comparison in Table 6a carries the unreachable state. The design can detect a post-rule rise in secured-state absence of about five percentage points, half the pre-rule rate, and finds none.

### 6.3 Stars against non-stars at two policy breaks

Table 6c [tab6c_absence_star_vs_nonstar] and Figure 4 compare stars with the control group. The event study regresses absence on star-by-season indicators with player, season, and team-game-number fixed effects. The post-rule coefficients, relative to 2023, are -0.008 (SE 0.018) in 2024, -0.019 (0.024) in 2025, and -0.018 (0.024) in 2026, with minimum detectable effects of 0.050, 0.068, and 0.068 [tabA1_absence_event_study]. No pre-period coefficient exceeds 0.035 or is distinguishable from zero. The pooled post-rule-by-star coefficient is -0.020 (0.016) across 2014 to 2026 and -0.023 (0.015) across 2022 to 2026, with minimum detectable effects of 0.044 and 0.043. For the September 2017 resting policy, the post-2017-by-star coefficient over 2014 to 2019 is 0.010 (0.016), minimum detectable effect 0.045.

Neither policy produced a detectable star-specific change in late-season absence. The design can detect changes of about four to seven percentage points against a base of eight to thirteen percent.

### 6.4 Nationally televised games

Broadcast strings are empty in the source before 2022, so a test of the PPP's national-television provision can use only 2022 and 2023 as the pre-period. Over that window, absence by healthy late-season stars in non-televised games went from 12.4 to 13.5 percent and in televised games from 11.2 to 7.2 percent [rest_tv_rates.csv]; the triple difference with player-season and game-number fixed effects is -0.022 (0.021) [rest_tv_ddd.csv]. Because the 2017 policy already protected televised games (ESPN 2023b), the comparison is between two regimes that both did so.

## 7. Mechanisms

### 7.1 The notch binds on few

Table 5c [tab5c_bound] and Appendix Figure A1 count, in each season, the stars with slack between 0 and 8 at team game 62. There are between 5 and 18 such stars per season, an average of 10.2 before the rule and 11.7 after, or a quarter of all stars [at_risk_bound_by_season.csv; tab5c_bound]. Of those, an average of 4.5 per season before the rule and 5.7 after finished short of 65.

Two bounds follow. Under minimal crossing, every at-risk star who fell short instead plays exactly enough additional qualifying games to reach 65. Summing those games and dividing by the number of stars gives the most the rule could have added to mean star qualifying games: 0.67 games per star-season in the pre-rule seasons and 0.98 in the post-rule seasons. Under the assumption that every at-risk star plays every remaining game, the bound is 1.27 games pre-rule and 1.83 post-rule. The upper limit of the pooled qualifying-games confidence interval is 6.50 games, and the minimum detectable effect is 6.8. Both bounds lie well inside.

This is the arithmetic of Chetty et al. (2011) applied to a notch: the aggregate response is the product of the share of agents at the margin and the response of each, and here the first factor is a quarter and the second is at most a few games out of sixty. The event studies of Section 5 are not a failure of the design; they are the design confirming what the population at the margin implied.

### 7.2 Star absences are spells, and spells rose for everyone

Appendix Table A3 [tabA3_long_absences] describes spells of ten or more consecutive missed games for stars and for the control group. Before the rule there were 127 star spells in 327 star-seasons, or 0.39 per star-season, and 33 percent of star-seasons contained one. After the rule there were 65 in 132 star-seasons, 0.49 per star-season, with 39 percent of star-seasons affected. Long spells account for 10.0 missed games per star-season before the rule and 11.0 after, out of a total absence rate between 14 and 32 percent of the schedule. Where a reason exists it is an injury or illness in 30 and 20 percent of spells; 56 and 77 percent have no row at any point; spells that begin with a rest or coach's-decision string are 11 percent before the rule and none after.

The rise in spells is not specific to stars. The control group went from 0.39 to 0.46 spells per player-season, an increase of 18 percent against the stars' 27 percent, and the share of player-seasons with a spell went from 34 to 38 percent against the stars' 33 to 39 [tabA3_long_absences; absences_rise_by_group.csv]. By season, star spells per star-season were 0.58 in 2023, 0.33 in 2024, 0.43 in 2025, and 0.75 in 2026; the control's were 0.35, 0.38, 0.48, and 0.56 [absences_by_season.csv]. The post-rule rise is concentrated in 2025 and 2026 for both groups and coincides with the league-wide increase in injuries reported for 2024-25 (Sportico 2025). One difference between the groups remains. The share of star spells beginning in the late-season window rose from 21 to 31 percent, while the control's fell from 32 to 26 percent (Figure A2). That is 20 of 65 post-rule star spells against 27 of 127 before, and it is the one number in the paper that points in the direction of the union's claim that players are playing hurt to reach the line. Section 8.2 says what the design can and cannot make of it.

A policy that addresses single nights off does not reach the spell margin. The rule and the PPP can change whether a healthy star sits out the second night of a back-to-back. They cannot change whether a star tears a ligament in February. Because absences of the second kind dominate the first by an order of magnitude, the aggregate availability of stars is determined mostly by something the policies do not touch.

### 7.3 Minutes

Appendix Table A2 [tabA2_minute_bins] tabulates the minutes played by late-season stars by whether they were tight, meaning slack of 0 to 3 with eligibility not yet secured. Among tight stars after the rule, 34.5 percent of player-games fell in the 23-to-30-minute bin against 29.4 percent before the rule, from a post-rule cell of 220 player-games and 18 players. Restricting to stars who had played each of the previous three games, which removes players on minute restrictions after injury, the shares are 30.5 and 29.5 percent on 46 post-rule games. There is no evidence here of managed minutes near the line. The one related movement is league-wide rather than slack-specific: the share of star appearances lasting at least 20 minutes rose from 0.972 in 2023 to 0.992 in 2024, after running 0.94 to 0.95 in 2015-2019 [qg_gp_ratio_by_group.csv]. Stars almost never play a short game after the rule. That is consistent with a coaching norm of not wasting a star's appearance on a non-qualifying game, and it is worth about one game per star-season.

## 8. Discussion

### 8.1 What the results show

Across every test the notch model suggests, the 65-game rule left no detectable mark on the availability of the players it was written for. There is no excess mass at 65. The stars nearest the line were no more likely to cross it. Star availability moved with the availability of comparable players, not away from it, and the one season in which it appeared to move away was a swing of a size the series had produced before and reversed after. Absence among stars who had just played did not rise in the states where the rule removed the incentive to play; it rose, by two percentage points, in the state where the incentive remained.

The reason is not that stars ignored the rule. It is that the rule could only matter to the quarter of stars within reach of the line in the season's final weeks, and that even a complete response by all of them would have added at most a game or two to the mean. The rest of star absence is injury, and injury is indifferent to award eligibility. This is the frictions reading of a null in Kleven (2016): not a zero elasticity, but a threshold placed where few agents can respond to it.

### 8.2 What the results do not show

The design bounds effects; it does not estimate them precisely. A star-specific gain of one to three games per season is inside every confidence interval reported and is the size the bounding argument allows. Readers who believe the rule changed a handful of seasons at the margin will find nothing here that contradicts them.

The design cannot test the hypothesis that the rule causes injury by inducing players to play hurt. That hypothesis predicts more long absences beginning late in the season among players near the line, and the paper contains a number that moves that way: the share of star spells beginning in the late window rose from 21 to 31 percent while the control's fell. Three things stand between that number and a test. The comparison rests on 20 post-rule spells. The rise in spells overall was league-wide, with 2025 and 2026 heavy injury seasons for both groups, so any star-specific timing shift sits on top of a common shock the design cannot net out with three post-rule seasons. And the source records no diagnosis, severity, or pre-injury workload, so a spell that begins at game 60 cannot be classified as an aggravation of something carried through games 50 to 59 or as a new event. A test would need injury reports with diagnosis and severity, a measure of workload in the games preceding onset, and a comparison of onset hazards between at-risk stars and stars far from the line at the same point in the season, with enough post-rule seasons for the injury cycle to average out. The paper reports the number so that it is not left unaddressed, and does not claim to have tested it.

The absence results rest on an outcome the source cannot decompose. A post-rule change in discretionary rest smaller than four to seven percentage points of late-season games would not be detected, and a change offset by a change in injury absence of the opposite sign would not be visible at all. The reason strings that exist say rest was a quarter of attributable late-season absences before the rule and a few percent after, but the attributable share itself fell from 45 to 19 percent, so the two periods are not comparable on this dimension.

Both control groups are partially treated. If All-Defensive, Most Improved, and Sixth Man candidates responded to the rule, the estimates are biased toward zero. The bounding argument does not depend on a control group at all. Three post-rule seasons is a short window, and the waivers granted in 2026 mean the notch is administered with discretion at the margin, which weakens the incentive for the players nearest the line in a way the model does not capture. The stakes could also grow as more contracts write bonuses against All-NBA selection, which would widen the set for whom the threshold is pivotal.

### 8.3 Implications

For the league, the results say that award eligibility is the wrong lever for the availability problem as it exists. The players whose absences drive the aggregate are injured, and the players who are healthy and choosing are few and already playing most nights. A rule that binds on ten players a season, each of whom can add a few games, has a ceiling of about one game per star, below the noise in a season's schedule. Whether schedule density can be reduced enough to move injury absence (Teramoto et al. 2017; Esteves et al. 2021) is a separate question that this paper's data cannot answer.

For the study of notches, the case is a useful negative. The bunching literature grew around settings where the population near the threshold is large relative to the whole, so that excess mass is visible in a histogram. Here the notch is clean, the prize is real and of a kind people respond to (Kosfeld and Neckermann 2011; Frey and Gallus 2017), and the population at the margin is small. The absence of bunching is evidence that the estimator has nothing to work with, not that the elasticity is zero. Reporting the size of the at-risk population and the bound it implies alongside the null, in the partially identified spirit of Bertanha, McCallum, and Seegert (2023), is the appropriate presentation, and we suggest it as a routine step in notch studies where the threshold sits far from the mass of the distribution.

For researchers using ESPN box scores through hoopR or similar tools, Table 2 is the practical result. The source does not record absences; it records some of them, and the share it records has changed over time and differs between stars and other players. Any panel built from box-score rows should be rebuilt on the schedule before absence or availability is measured.

## References

Allen, Eric J., Patricia M. Dechow, Devin G. Pope, and George Wu. 2017. "Reference-Dependent Preferences: Evidence from Marathon Runners." *Management Science* 63 (6): 1657-1672. doi:10.1287/mnsc.2015.2417.

Applied Economics Letters. 2026. "The contract year phenomenon: investigating the effect of contract uncertainty on NBA player performance." Advance online. doi:10.1080/13504851.2026.2629455. [Authorship to be confirmed via CrossRef before submission.]

arXiv 2402.12400. 2024. "Estimating the age-conditioned average treatment effects curves: an application for assessing load-management strategies in the NBA."

Bergé, Laurent. 2018. "Efficient estimation of maximum likelihood models with multiple fixed-effects: the R package FENmlm." CREA Discussion Papers 13, University of Luxembourg.

Berri, David J., and Anthony C. Krautmann. 2006. "Shirking on the Court: Testing for the Incentive Effects of Guaranteed Pay." *Economic Inquiry* 44 (3): 536-546. doi:10.1093/ei/cbj019. [DOI to verify.]

Bertanha, Marinho, Andrew H. McCallum, and Nathan Seegert. 2023. "Better bunching, nicer notching." *Journal of Econometrics* 237 (2): 105512. doi:10.1016/j.jeconom.2023.105512.

Bertrand, Marianne, Esther Duflo, and Sendhil Mullainathan. 2004. "How Much Should We Trust Differences-in-Differences Estimates?" *Quarterly Journal of Economics* 119 (1): 249-275. doi:10.1162/003355304772839588.

CBS Sports. 2024. "Pirates cut Rowdy Tellez four plate appearances shy of $200K bonus." September 25, 2024.

Chan, Ho Fai, Bruno S. Frey, Jana Gallus, and Benno Torgler. 2014. "Academic honors and performance." *Labour Economics* 31: 188-204. doi:10.1016/j.labeco.2014.05.005.

Chetty, Raj, John N. Friedman, Tore Olsen, and Luigi Pistaferri. 2011. "Adjustment Costs, Firm Responses, and Micro vs. Macro Labor Supply Elasticities: Evidence from Danish Tax Records." *Quarterly Journal of Economics* 126 (2): 749-804. doi:10.1093/qje/qjr013.

Ehrenberg, Ronald G., and Michael L. Bognanno. 1990. "Do Tournaments Have Incentive Effects?" *Journal of Political Economy* 98 (6): 1307-1324. doi:10.1086/261736.

ESPN. 2023a. Wojnarowski, Adrian, Bobby Marks, and Jeff Zillgitt. "NBA board of governors approve tougher rest rule." September 13, 2023. https://www.espn.com/nba/story/_/id/38392750/.

ESPN. 2023b. Marks, Bobby. "Answering the big questions about the NBA's new rules on resting stars." September 2023. https://www.espn.com/nba/story/_/id/38386013/.

ESPN. 2026. "Luka Doncic, Cade Cunningham awards eligible; Edwards denied." April 16, 2026. https://www.espn.com/nba/story/_/id/48504211/.

Esteves, Pedro T., et al. 2021. "Basketball performance is affected by the schedule congestion: NBA back-to-backs under the microscope." *European Journal of Sport Science* 21 (1): 26-35. doi:10.1080/17461391.2020.1736179.

Forbes. 2026. Toporek, Bryan. "'Extraordinary Circumstances' Further Muddle NBA's 65-Game Awards Rule." April 18, 2026.

Frey, Bruno S., and Jana Gallus. 2017. *Honours versus Money: The Economics of Awards*. Oxford: Oxford University Press. doi:10.1093/oso/9780198798507.001.0001.

Fumarco, Luca, Neil Longley, Alberto Palermo, and Giambattista Rossi. 2024. "Strategic behaviours in a labour market with mobility-restricting contractual provisions: evidence from the National Hockey League." *Oxford Economic Papers* 76 (4): 1189-1203. doi:10.1093/oep/gpae010.

Gilani, Saiem. 2021. *hoopR: The SportsDataverse's R Package for Men's Basketball Data*. doi:10.32614/CRAN.package.hoopR.

Hausman, Jerry A., and Gregory K. Leonard. 1997. "Superstars in the National Basketball Association: Economic Value and Policy." *Journal of Labor Economics* 15 (4): 586-624. doi:10.1086/209839.

Kahn, Lawrence M. 2000. "The Sports Business as a Labor Market Laboratory." *Journal of Economic Perspectives* 14 (3): 75-94. doi:10.1257/jep.14.3.75.

Kaplan, Scott M. 2022. "Putting a price on popularity: Evidence from superstars in the National Basketball Association." *Economic Inquiry* 60 (3): 1357-1381. doi:10.1111/ecin.13065.

Kaplan, Scott, Vaibhav Ramamoorthy, Cheenar Gupte, Amit Sagar, Deepak Premkumar, Joshua Wilbur, and David Zilberman. 2019. "The Economic Impact of NBA Superstars: Evidence from Missed Games using Ticket Microdata from a Secondary Marketplace." MIT Sloan Sports Analytics Conference.

Kessock, Patrick. 2016. "Out of Service: Does Service Time Manipulation Violate Major League Baseball's Collective Bargaining Agreement?" *Boston College Law Review* 57 (4): 1367-1402.

Kleven, Henrik J. 2016. "Bunching." *Annual Review of Economics* 8: 435-464. doi:10.1146/annurev-economics-080315-015234.

Kleven, Henrik J., and Mazhar Waseem. 2013. "Using Notches to Uncover Optimization Frictions and Structural Elasticities: Theory and Evidence from Pakistan." *Quarterly Journal of Economics* 128 (2): 669-723. doi:10.1093/qje/qjt004.

Kosfeld, Michael, and Susanne Neckermann. 2011. "Getting More Work for Nothing? Symbolic Awards and Worker Performance." *American Economic Journal: Microeconomics* 3 (3): 86-99. doi:10.1257/mic.3.3.86.

Krautmann, Anthony C., and Thomas D. Donley. 2009. "Shirking in Major League Baseball: Revisited." *Journal of Sports Economics* 10 (3): 292-304. doi:10.1177/1527002508325817.

Lazear, Edward P., and Sherwin Rosen. 1981. "Rank-Order Tournaments as Optimum Labor Contracts." *Journal of Political Economy* 89 (5): 841-864. JSTOR 1830810. [DOI to verify.]

Mack, Christina D., Mackenzie M. Herzog, John P. DiFiori, Peter L. Meisel, and Nancy A. Dreyer. 2018. "A second look at NBA game schedules: Response to Teramoto et al." *Journal of Science and Medicine in Sport* 21 (3): 228-229. doi:10.1016/j.jsams.2017.07.023.

NBA. 2023. "NBA Board of Governors approves new Player Participation Policy." NBA Communications, September 13, 2023. https://pr.nba.com/nba-board-of-governors-approves-player-participation-policy.

NBA.com. 2023. "Adam Silver discusses new policy as load management goes 'too far.'" September 2023.

Neckermann, Susanne, Reto Cueni, and Bruno S. Frey. 2014. "Awards at work." *Labour Economics* 31: 205-217. doi:10.1016/j.labeco.2014.04.002.

PLOS ONE. 2022. "Epidemiology and injury trends in the National Basketball Association: Pre- and per-COVID-19 (2017-2021)." *PLOS ONE* 17 (2): e0263354. doi:10.1371/journal.pone.0263354. [Author list to be completed from the record.]

Pope, Devin, and Uri Simonsohn. 2011. "Round Numbers as Goals: Evidence from Baseball, SAT Takers, and the Lab." *Psychological Science* 22 (1): 71-79. doi:10.1177/0956797610391098.

Price, Joseph, Brian P. Soebbing, David Berri, and Brad R. Humphreys. 2010. "Tournament Incentives, League Policy, and NBA Team Performance Revisited." *Journal of Sports Economics* 11 (2): 117-135. doi:10.1177/1527002510363103.

Rosen, Sherwin. 1981. "The Economics of Superstars." *American Economic Review* 71 (5): 845-858. JSTOR 1803469.

Saez, Emmanuel. 2010. "Do Taxpayers Bunch at Kink Points?" *American Economic Journal: Economic Policy* 2 (3): 180-212. doi:10.1257/pol.2.3.180.

Sportico. 2023. "Ja Morant's All-NBA snub and the supermax." May 2023.

Sportico. 2024. Novy-Williams, Eben, and Steve Impey. "NBA Awards, Load Management Policy Reduced Missed Games by Stars." April 2024.

Sportico. 2025. "NBA Policies Curb Star Absences Amid Spike in Overall Injuries." May 21, 2025.

Stiroh, Kevin J. 2007. "Playing for Keeps: Pay and Performance in the NBA." *Economic Inquiry* 45 (1): 145-161. doi:10.1111/j.1465-7295.2006.00004.x.

Taylor, Beck A., and Justin G. Trogdon. 2002. "Losing to Win: Tournament Incentives in the National Basketball Association." *Journal of Labor Economics* 20 (1): 23-41. doi:10.1086/323930.

Teramoto, Masaru, Chad L. Cross, Daniel M. Cushman, Travis G. Maak, David J. Petron, and Stuart E. Willick. 2017. "Game injuries in relation to game schedules in the National Basketball Association." *Journal of Science and Medicine in Sport* 20 (3): 230-235. doi:10.1016/j.jsams.2016.08.020.

White, Mark H., II, and Kennon M. Sheldon. 2014. "The contract year syndrome in the NBA and MLB: A classic undermining pattern." *Motivation and Emotion* 38: 196-205. doi:10.1007/s11031-013-9389-7. [DOI to verify.]

---

### Tables and figures

Main text: Table 1 `tab1_sample`; Table 2 `tab2_source_coverage`; Table 3 `tab3a_availability_event_study`, `tab3b_availability_pooled`; Table 4 `tab4a_bunching_bins`, `tab4b_bunching_excess_mass`; Table 5 `tab5a_at_risk_reach`, `tab5b_at_risk_regressions`, `tab5c_bound`; Table 6 `tab6a_absence_by_state`, `tab6b_absence_state_regressions`, `tab6c_absence_star_vs_nonstar`. Figures 1-4: `fig1_bunching_histogram`, `fig2_availability_event_study`, `fig3_absence_by_state` (pre/post bars by state with confidence intervals), `fig4_absence_stars_vs_nonstars`.

Appendix: Tables A1-A9 (`tabA1_absence_event_study`, `tabA2_minute_bins`, `tabA3_long_absences`, `tabA4_absence_reasons`, `tabA5_bbr_validation`, `tabA6_stars_no_appearance`, `tabA7_exhibition_correction`, `tabA8_composition_2024`, `tabA9_cohort_pairs`); Figures A1-A3 (`figA1_at_risk_by_season`, `figA2_absence_timing` with both groups, `figA3_absence_by_state_by_season`).

### Changes from v1

1. Control group redefined on prior-season status (Section 4.2); the current-season definition with the rostered-games filter selected on the outcome. All availability and absence estimates re-run; the exploratory design is retained as a labeled comparison row.
2. Section 5.2 added: decomposition of the 2024 change into composition and within-player components, and fixed-cohort adjacent-season comparisons (Tables A8, A9). Both v1 passages describing the control as having "matched" or "risen by less" are gone.
3. Intro prize sentence corrected: direction versus magnitude.
4. Long spells now compared with the control group (Table A3, Figure A2), the league-wide rise stated, the star-specific late-onset shift reported, and a paragraph in 8.2 on why the play-hurt hypothesis cannot be tested here and what would be needed.
5. Figure 3 is a pre/post bar chart with confidence intervals; the season series moved to Figure A3.
6. Section 6.2 states the significant rise in reachable-state absence and calls the unreachable-by-post regression uninformative.
7. Section 7.3 shrunk to one paragraph; "suggestive" removed; the league-wide rise in the star qualifying share reported instead.
8. MDE convention stated once, in Section 5.1, with clustering cited.
9. Background section added, literature incorporated throughout, references added. Items the bibliography flags as unverified are marked.
