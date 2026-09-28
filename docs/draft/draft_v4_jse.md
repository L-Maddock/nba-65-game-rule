# A Bright Line That Binds on Few: The NBA's 65-Game Rule and Star Availability

## Title Page

Author: Luke Maddock
Affiliation: Department of Data Analytics, Denison University
Address: 100 West College Street, Granville, OH 43023, USA
Email: jlmaddock1@gmail.com
Phone: [phone]
Fax: [fax]
ORCID: [ORCID iD]
Corresponding author: Luke Maddock, Department of Data Analytics, Denison University, 100 West College Street, Granville, OH 43023, USA; [phone]; jlmaddock1@gmail.com
Acknowledgments: [Acknowledgments to be added.]
Funding: The author received no financial support for the research, authorship, or publication of this article.
Declaration: The author declares no conflicts of interest. The manuscript is not under review elsewhere.

## Abstract

In 2023-24 the National Basketball Association made eligibility for its major individual awards conditional on appearing in 65 regular-season games of at least 20 minutes. The rule is a notch, and notches predict bunching at the threshold, play-through by players just short of it, and slack once eligibility is settled. Over 2013-14 through 2025-26, I find no detectable change in games played: no excess mass at 65, no rise in the share of stars near the line who cross it, and a change in star availability relative to comparable players of -0.8 games (SE 2.3). Half of the rise in star games that the league cited after the rule's first season was a change in who the stars were. Only a quarter of stars are within reach of the line late in the season, and a full response would add at most 1.3 games to the star mean.

*Keywords:* notches, bunching, awards, labor supply, National Basketball Association

## Text

In April 2024 the commissioner of the National Basketball Association (NBA) reported that games missed by star players had fallen about 15% in the first season of the league's 65-game award-eligibility rule (Novy-Williams & Impey, 2024). The raw numbers agree: stars averaged 59.4 games in 2022-23 and 65.0 in 2023-24 (Table 1). Half of that rise was a change in who the stars were. The seven players who entered the star set in 2023-24 averaged 69.6 games, and the six who left had averaged 46.7 the season before. The 39 players who were stars in both seasons played 2.9 more games, a within-player rise of a size the same comparison had produced from 2015 to 2016 and would produce, in the other direction, from 2025 to 2026 (Appendix Tables A7 and A8). This article asks whether the rule changed star behavior at all, and answers with bounds.

The rule is a notch in the sense of Kleven and Waseem (2013). To be eligible for Most Valuable Player, Defensive Player of the Year, and the All-NBA and All-Defensive teams, a player must appear in 65 regular-season games of at least 20 minutes, with an allowance of two games between 15 and 19 minutes. Below the line the award system offers nothing; at the line it offers full eligibility. Notches predict mass at the threshold, play-through by agents just short of it, and slack once eligibility is either secured or out of reach. The direction of these predictions does not depend on the size of the prize; the magnitude does, which is why the mechanisms section counts the players for whom the prize is large and pivotal. Where that population is thin, the bunching literature has long recognized that no visible response should be expected (Chetty et al., 2011; Kleven, 2016; Saez, 2010).

I test each prediction on every player-game from 2013-14 through 2025-26, for the 36 to 46 players per season who meet the league's own definition of a star. There is no excess mass at 65. Stars within a few games of the line late in the season were no more likely to cross it after the rule than before. Star availability relative to a control group defined on prior-season status did not change in any post-rule season; the pooled estimate for games played is -0.8 (SE 2.3) with a minimum detectable effect of 6.5 games. Late-season absence among stars who had played the previous game did not rise in the states where the rule removes the incentive to play. The reason is that the rule can matter only to the quarter of stars within reach of the line in the season's final weeks, and a complete response by all of them would add between 0.7 and 1.3 games to the star mean, inside every interval reported. Star absence is dominated by spells of ten or more games, which the rule does not touch. On the adjacent margin of minutes the evidence is mixed: within player, the share of star appearances lasting 20 minutes rose after the rule, but the star share was already near one in 2023 and the raw change against that season is under half a point.

The article makes three contributions. To my knowledge it is the first econometric evaluation of the rule or of the Player Participation Policy (PPP) adopted alongside it; the nearest academic work studies the performance effects of rest by age and cites the policy only as motivation (Nakamura-Sakai et al., 2024). To the literature on notches it adds a case in which a clean notch with real stakes produced no detectable response on the targeted margin and at most a fragile one on an adjacent margin, and it traces the null to the size of the population at the margin rather than to a zero elasticity. And it documents, for users of ESPN box scores, that the source carries only players on the active list, so that absence must be measured on the schedule. The next section reviews the rule and the literatures the article draws on; later sections set out a model, describe the data, report availability and absence results, formalize the mechanisms, and discuss what the results do and do not show.

### Background

#### The Rule and the Policies Around It

Figure 1 places the policies on a timeline. The 65-game rule was ratified in the April 2023 collective bargaining agreement and applied from 2023-24. A game counts if the player plays at least 20 minutes; up to two games of 15 to 19 minutes also count. Rookie of the Year is exempt (Marks, 2023). The in-season tournament final counts toward the threshold although it is excluded from regular-season statistics (Sports Illustrated, 2026). There is an exception for season-ending injuries after 62 qualifying games and a provision for extraordinary circumstances. In April 2026 the league and the union ruled two players eligible under that provision, one at 64 qualifying games who missed two games for the birth of a child and one at 63 after a collapsed lung, while a third, at 60, took his case to an arbitrator and lost (ESPN, 2026; Toporek, 2026). My counts for those three players are 64, 63, and 60. A fourth player reached 65 in the season's penultimate game by playing 26 minutes through bruised ribs, his 64 regular-season games plus the tournament final (Associated Press, 2026); my count is 64 regular-season games and 65 under the rule (Appendix Table A14).

The stakes are large for a minority. All-NBA selection triggers salary escalators and eligibility for the largest contract tiers, and one player's exclusion from the 2023 teams was reported to cost him 39 million dollars over five seasons (Novy-Williams, 2023). For the median star the stakes are smaller. The rule was written against a specific fact: in 2023, five of the fifteen All-NBA selections had played fewer than 65 games (Hoops Rumors, 2024).

The PPP took effect in the same season. It defines a star as a player selected to an All-Star or All-NBA team in any of the prior three seasons, requires teams to keep healthy stars available for nationally televised and tournament games, forbids resting two stars in one game, requires a balance of home and road absences, bars long shutdowns of healthy players, and fines teams 100,000 dollars for a first violation, 250,000 for a second, and one million more than the previous penalty thereafter (National Basketball Association, 2023a; Wojnarowski et al., 2023). A resting policy adopted in September 2017 already barred resting healthy players on national television and resting several players at once, and the league restated it twice before the PPP. A November 2019 memo barred teams from labeling a healthy player's absence "load management" and reminded them that healthy players could not sit high-profile televised games; the Clippers were fined 50,000 dollars that month over statements about Kawhi Leonard's health that the league found inconsistent with his status (CBS Sports, 2019; Pelton & Arnovitz, 2019). A December 2020 memo for the condensed pandemic season reaffirmed the television-game prohibition, with a fine of at least 100,000 dollars, while allowing rest in non-televised games for back-to-backs, veterans coming off a long playoff run, and players recovering from COVID-19 (Bontemps, 2020; NBC Sports, 2020). The PPP's additions were the star definition, the escalating fines, the roster-balance and no-shutdown provisions, and enforcement (Marks, 2023). The PPP acts on the team, not the player, and the commissioner described its purpose as reining in load management that had "gotten away from us a bit" (National Basketball Association, 2023b).

#### Related Literature

Saez (2010) compared the density of taxable income around kink points with a smooth counterfactual and recovered elasticities from the excess mass; his headline result is a set of nulls. Chetty et al. (2011) showed that optimization frictions attenuate bunching and that kinks affecting larger groups produce larger observed responses. Kleven and Waseem (2013) extended the method to notches, and Kleven (2016) states the caveat that governs this article: absence of bunching implies either a low structural elasticity or high frictions, and the data around the threshold cannot separate them. Bertanha et al. (2023) provide inference for the partially identified case. Thresholds in sport have produced clear bunching where the threshold sits near the center of the outcome distribution and the marginal action is cheap: batters entering a season's final at-bat at .298 or .299 hit .463 in it (Pope & Simonsohn, 2011), and marathon times pile up just under round numbers (Allen et al., 2017). A games threshold sits in the upper tail of a distribution shaped by injury, and the marginal action is unavailable to an injured player.

The rule conditions access to a rank-order tournament (Lazear & Rosen, 1981; Ehrenberg & Bognanno, 1990). Awards without money attached also move behavior (Chan et al., 2014; Frey & Gallus, 2017; Kosfeld & Neckermann, 2011; Neckermann et al., 2014), which justifies treating All-NBA selection as an incentive even where no bonus is written into a contract. Sports data have long served as a labor-market laboratory (Kahn, 2000). NBA players respond to individual financial incentives at some margins and not others (Berri & Krautmann, 2006; Owsik & Tan, 2026; Stiroh, 2007; White & Sheldon, 2014), and teams respond to bright-line league rules (Fumarco et al., 2024; Price et al., 2010; Taylor & Trogdon, 2002), including by managing a games threshold against a player's interest (CBS Sports, 2024). Star availability matters because a few performers capture a disproportionate share of a market's value (Rosen, 1981): Hausman and Leonard (1997) put the value of one star to the other teams at about 53 million dollars, and Kaplan (2022) found that a superstar's announced absence lowers secondary-market ticket prices by 4% to 22% (see also Kaplan et al., 2019). On the supply side, game injuries track schedule density (Esteves et al., 2021; Mack et al., 2018; Teramoto et al., 2017), and the league records more than 800 injuries per season, concentrated in the middle and late season (Torres-Ronda et al., 2022). League figures for 2024-25 reported stars missing 19% of games to injury in each post-rule season, the same as in 2017-18 and 2018-19 (Sportico, 2025). A search of SSRN, NBER, arXiv, the MIT Sloan Sports Analytics Conference, and Google Scholar returned no article, working paper, or thesis that evaluates the rule or the PPP as its research question.

### A Simple Model

> "I guess use your 17 games as wisely as possible." Bam Adebayo, January 2024, on the 65-game rule (Hoops Rumors, 2024).

Consider a star deciding, game by game, whether to play. Let $q$ be the number of qualifying games so far, $r$ the number of games remaining, and $\bar q = 65$ the threshold. Each game played yields a flow benefit $b$ and carries a cost $c_g$ that varies with fatigue, minor injury, and schedule. Eligibility is worth $V \geq 0$ and is received if and only if $q \geq \bar q$ at season's end. Before the rule $V$ enters continuously through voters' impressions; after it, as a step.

Four predictions follow. A player who reaches exactly 65 has no further eligibility motive to play, so mass should collect at the threshold and thin just above it. Define slack as $q + r - \bar q$, the number of remaining games a player can miss and still reach the line. For players with small non-negative slack late in the season, the option value of eligibility raises the return to playing through a marginal cost, so the share reaching 65 should rise after the rule. Once slack is negative or $q \geq \bar q$, the marginal eligibility incentive is zero, so absence in those states should rise relative to the reachable state. And because a game counts only at 20 minutes, the share of star appearances lasting at least 20 minutes should rise; this margin requires no additional appearance, only that an appearance already being made be long enough to count.

The magnitude of every prediction scales with $V$ and with the number of players for whom the threshold is pivotal. A player who would have played 75 games regardless is unaffected; so is a player whose injury ends the season at 40. The PPP pushes against the third prediction: its fines apply in every state, so it predicts a uniform fall in discretionary absence.

### Data

#### Sources and Definitions

Player-game box scores come from ESPN through hoopR (Gilani, 2021), for regular seasons 2013-14 through 2025-26; seasons are indexed by end year. The 2019-20 and 2020-21 seasons are excluded from every estimate. Honors come from Basketball-Reference pages cached once, with the 2025 and 2026 All-Star rosters entered by hand. Estimation uses fixest (Bergé, 2018).

A star in season $s$ is a player who made an All-Star or All-NBA team in any of seasons $s-3$ to $s-1$, the PPP's definition; because it is lagged it cannot respond to the treatment. There are 36 to 46 stars per season with at least one appearance (Table 1). The control group is defined the same way, on prior-season status: players who are not stars in season $s$ and who in season $s-1$ averaged at least 28 minutes per game and played at least 40 games. They number 68 to 90 per season from 2015 on. A robustness control uses rotation players, 20 or more minutes and 40 or more games in the prior season. Defining the control on the prior season matters. An earlier version of this analysis defined it on current-season minutes and games, which selects on the outcome: a control player could not have missed more than 42 games while a star could have missed 80, and the accompanying filter on rostered games truncated the stars' low tail. That design is retained as a labeled comparison row in Table 4. Both controls are partially treated, since All-Defensive, Most Improved, and Sixth Man awards carry the same requirement.

Qualifying games follow the rule's definition and include the tournament final; games played is the regular-season statistic and excludes it, so the two can differ by one for players on the two finalist teams. Table 1, Figure 2, and every threshold calculation use the rule's definition. Slack and eligibility state are defined at the player-game level as in the model. The late-season window is team game 56 onward. A player is *healthy* entering a game if he played his team's previous game.

#### What ESPN Box Scores Contain

An ESPN box score carries the players on a team's active list for that game: those who played, and those who dressed and did not play, who appear as a row with a reason string. Players on the inactive list, whether injured, ill, away from the team, or resting, do not appear at all. I verified this against seven Basketball-Reference box scores spanning 2015 to 2026, chosen so that a star had an absence with no ESPN row. All 40 ESPN did-not-play rows in those games appear inside the Basketball-Reference box as did-not-play or did-not-dress; none of the 51 players listed as inactive has an ESPN row; and all seven stars are on the inactive list (Appendix Table A13).

The distinction matters because the two absence types have moved in opposite directions. Table 2 reports the share of absences that appear as a dressed-but-unused row. For stars it was 28% to 40% in 2014 through 2017, 15% in 2018 and 2019, 7% to 10% in 2022 through 2024, and 8% to 16% after. For the control it fell from 30% to 38% in 2015-2017 to between 9% and 23% from 2022 on. The total absence rate of stars did not fall; it was between 14% and 32% of team-games in every season. Teams moved absent players from the bench to the inactive list. Any outcome computed from box-score rows therefore tracks roster designation, not behavior, and neither designation maps to rest versus injury.[^rows] I build the player-game panel on the full schedule of each player's team stints, with a flag for whether a row exists.

[^rows]: An exploratory construction that counted only games with a row produced star "rest" rates of 7.1% in 2014 and 1.1% in 2023, a fall that coincides with the fall in row coverage in Table 2. The rows-only raw rates are in Appendix Table A19, and the rows-only event-study coefficients are the last column of Appendix Table A5.

Two smaller corrections. ESPN files the All-Star and Rising Stars games as regular-season games; removing those rows lowers qualifying games by one for ten to seventeen stars per season through 2024, and three star-seasons cross 65 only because of them (Appendix Table A15). Fourteen flagged star-seasons outside the pandemic years have no appearance, mostly retired players still flagged from earlier honors (Appendix Table A18). A check of ten star-seasons against Basketball-Reference finds all nine with a reference value matching exactly; the tenth played no games (Appendix Table A14).

The same source property limits what can be learned about rest. Among late-season absences by stars who had played the previous game, 45% had a dressed-but-unused row before the rule and 19% after. Of the reasons given, rest and coach's decision account for a quarter of all such absences before the rule and 2.6% after; the remainder are injury strings or inactive-list absences with no reason (Appendix Table A17). Discretionary rest and new injury cannot be separated in this source.

#### The Sample

Table 1 describes the sample. Stars averaged 59.4 games in 2023 and 65.0 in 2024; the share with at least 65 qualifying games went from 0.44 to 0.67. Both fell back in 2025 and 2026, to 62.4 and 54.8 games and to 0.54 and 0.47. The control averaged 65.6 games in 2023, 66.1 in 2024, 62.0 in 2025, and 58.8 in 2026.

### Availability Results

#### Event Studies

Figure 3 and Table 3 report event-study estimates of star availability relative to the control, with 2023 as the reference season, from a regression of games played or qualifying games on star-by-season indicators with player and season fixed effects, on all star and control player-seasons from 2015 to 2026 with no filter on the outcome. Standard errors are clustered by player throughout (Bertrand et al., 2004). Every null is accompanied by its minimum detectable effect, defined once here as the effect detected with 80% power in a two-sided 5% test given the estimated standard error, 2.80 times that standard error. The sample is 1,093 player-seasons of 255 players (Table 4).

The post-rule coefficients for games played are -0.41 (SE 2.95) in 2024, -0.20 (3.00) in 2025, and -2.87 (4.48) in 2026, with minimum detectable effects of 8.3, 8.4, and 12.6 games. Pre-period coefficients lie between -5.30 and 3.28 and none is distinguishable from zero. Qualifying games give 2.04 (3.15), 2.00 (3.11), and -0.12 (4.59). Pooling the post-rule seasons (Table 4), the star-specific change in games played is -0.81 (2.32), with a 95% interval from -5.37 to 3.75 games and a minimum detectable effect of 6.5. For qualifying games it is 1.72 (2.45) with an upper limit of 6.52. The share at or above 65 rises by 0.067 (0.070), minimum detectable effect 0.20. The blue band in Figure 3 shows the pooled interval so that the reader sees one bound rather than eleven wide whiskers.

The rotation control gives 2.47 (2.14) for games played but 6.81 (2.30) for qualifying games, with a 2017 coefficient of 5.10 (2.27). I do not read the qualifying-games result as a rule effect. A rotation player's qualifying count sits on the 20-minute margin: the group's ratio of qualifying games to games played is 0.64 to 0.73 across seasons against 0.97 to 0.99 for stars, so for that group the outcome measures minutes, and the mechanisms section treats the minutes margin directly. The exploratory design, with the current-season control and the rostered-games filter, gives 1.05 (1.41) pooled; its narrower interval comes from truncating the stars' low tail.

#### What Happened in 2024

Appendix Table A7 decomposes the 5.6-game rise in mean star games from 2023 to 2024, against a control change of 0.6. The 39 players who were stars in both seasons went from 61.3 to 64.2, a rise of 2.9. The seven entrants averaged 69.6 games; the six leavers had averaged 46.7 in 2023. Half of the raw rise is composition and half is a within-player rise. Among control stayers, games played fell by 3.8. Appendix Table A8 estimates a fixed-cohort difference-in-differences for every pair of adjacent seasons, with groups fixed at their status in the first season and players present in both. The 2023-to-2024 estimate is 4.66 (SE 3.44, *p* = .18). The five pre-rule pairs range from -3.59 to 4.15; 2024-to-2025 gives 3.91 and 2025-to-2026 gives -5.16. The rule's first season produced the largest adjacent-season swing in the series, by half a game, and the swing reversed in the next two seasons.

#### Bunching at 65

Figure 2 plots the distribution of qualifying games for star player-seasons before and after the rule, with the pre-rule distribution overlaid on the post-rule panel as the counterfactual (Kleven & Waseem, 2013; Saez, 2010). The share of star-seasons in the bin just below the threshold, 58 to 64 games, is 0.122 before and 0.114 after; just above, 65 to 68, it is 0.125 and 0.106 (Appendix Table A1).

Table 5 reports an excess-mass estimator with the pre-rule distribution of 327 star-seasons scaled to the 132 post-rule star-seasons as the counterfactual, *b* the excess count in a window above 65 divided by the mean counterfactual mass per one-game bin in that window, *m* the analogous statistic below, and intervals from 2,000 bootstrap resamples. At exactly 65 games there are 7 post-rule star-seasons against a counterfactual of 3.6, for *b* = 0.93 with a 95% interval from -0.38 to 4.57. Widening to 65 and 66 gives 7 against 8.9, *b* = -0.42 [-1.45, 1.30]; widening to 65 through 68 gives 14 against 16.6, *b* = -0.62 [-2.24, 1.81]. No window rejects zero. With only 2022 and 2023 as the counterfactual the estimates turn negative, *b* = -2.22 [-3.11, -0.76] for the widest window, because those two seasons placed unusual mass just above 65.

#### At-Risk Stars and the Case Table

At team game 62, with twenty games remaining, a star with slack between 0 and 8 can still reach 65 but cannot miss many more games. Appendix Table A2 reports, for stars also healthy at game 62, whether they finished with 65. Post-rule there are 2 such stars with slack 0 to 2, 8 with slack 3 to 5, and 11 with slack 6 to 8, with reach rates of 1.00, 0.62, and 0.64 against pre-rule rates of 0.40, 0.70, and 0.60 from 20, 27, and 25 star-seasons; Fisher exact *p* values are .19, .69, and 1.00. A linear probability model pooling the bins (Appendix Table A3) gives a post-rule change of 0.06 (SE 0.13) among healthy at-risk stars, minimum detectable effect 0.35, from 21 post-rule observations. These tests cannot detect a change in the reach probability smaller than about a third.

Table 7 lists every one of those 21 post-rule star-seasons: slack at game 62, whether the player reached 65, the minutes of his first four appearances after his last absence before game 62, and the stakes attached to eligibility where I could establish them from contract reporting. The table is the population the rule was written for, and it is small enough to read. Three patterns stand out. First, the return-minutes column contains the managed re-entry the rule predicts: after his last pre-62 absence in 2024, one player returned for four games of 22, 22, 22, and 20 minutes, each one qualifying game more than an 18-minute appearance would have been, and a second player in 2026 returned at 21, 26, 26, and 27. Most returners went straight back to 30-plus minutes. Second, the stakes column shows why: the two players with managed returns had a Rose Rule escalator or qualification riding on All-NBA selection, while most of those who fell short had no award-linked contract term. Third, of the seven post-rule star-seasons at exactly 65, three belong to healthy at-risk stars with slack of 1, 2, and 3 at game 62, who landed on the line and stopped.

That third pattern is the notch's individual-level fingerprint, and Appendix Table A10 puts a number on it. Among at-risk stars who reached 65, 8 of 46 finished at exactly 65 before the rule and 6 of 18 after, 17% against 33%, Fisher *p* = .19. Among healthy at-risk reachers the shares are 19% and 36%, *p* = .27. Before the rule, at-risk reachers spread across 65 to 72, with 66 the modal finish; after it, six of eighteen sit on 65 and none on 66 (Appendix Table A11). The pattern is what "secure and sit" produces, on the only population where it could appear, and it is a handful of players.

### Absence Behavior

The outcome in this section is absence: a player did not play a late-season game after having played his team's previous game. On the full schedule this rate runs between 7.9% and 13.2% of star player-games across seasons. It includes players injured in the game they had just played and players who chose to sit, and the source cannot separate them. Nothing here should be read as a rest rate. The design can detect changes of four to seven percentage points in this rate.

#### Absence by Eligibility State

Table 8 and Figure 4 report absence by eligibility state. Before the rule, healthy late-season stars were absent from 7.1% of games in the reachable state, 10.8% when eligibility was secured, and 14.6% when 65 was out of reach. After the rule the rates are 9.1%, 12.4%, and 16.1%. The reachable-state rise of 2.0 points (SE 0.9) is the one change distinguishable from zero, and it is in the state where the notch predicts a fall. The secured and unreachable states, where the notch predicts a rise, changed by 1.5 (1.5) and 1.4 (2.0). The gradient across states is present in both periods and is what an injury process produces without any incentive.

Appendix Table A4 puts the secured-versus-reachable comparison in a regression with player-season and team-game-number fixed effects, so that the interaction is identified from players who move between states within a late season. The secured-by-post coefficient is -0.011 (SE 0.019), with a minimum detectable effect of 0.053; the collapsed no-incentive interaction is -0.005 (0.019). The unreachable state is omitted from the regression: within a player-season its games follow a long absence, so the within-player contrast is mechanically negative, and the post interaction is identified from too few transitions to be informative. The design can detect a post-rule rise in secured-state absence of about five percentage points, half the pre-rule rate, and finds none.

#### Stars Against the Control at Two Policy Breaks

Table 9 and Figure 5 compare stars with the control. The post-rule coefficients relative to 2023 are -0.008 (SE 0.018) in 2024, -0.017 (0.025) in 2025, and -0.018 (0.024) in 2026, with minimum detectable effects of 0.050, 0.069, and 0.068 (Appendix Table A5); no pre-period coefficient exceeds 0.035. The pooled post-rule-by-star coefficient is -0.019 (0.016) across 2014 to 2026 and -0.023 (0.015) across 2022 to 2026, minimum detectable effects 0.044 and 0.043. For the September 2017 resting policy, the post-2017-by-star coefficient over 2014 to 2019 is 0.010 (0.016). Neither policy produced a detectable star-specific change in late-season absence.[^tv]

[^tv]: Broadcast strings are empty in the source before 2022, so the PPP's national-television provision can be tested only against 2022 and 2023, and both regimes protected televised games. Over that window, absence by healthy late-season stars in non-televised games went from 12.4% to 13.5% and in televised games from 11.2% to 7.2%; the triple difference with player-season and game-number fixed effects is -0.023 (0.021). The test cannot distinguish the PPP from the 2017 policy and I do not use it.

### Mechanisms

#### The Notch Binds on Few

Table 6 and Appendix Figure A1 count, in each season, the stars with slack between 0 and 8 at team game 62. There are between 5 and 18 such stars per season, an average of 10.2 before the rule and 11.3 after, a quarter of all stars. Of those, 4.5 per season before the rule and 5.3 after finished short of 65. Two bounds follow. Under minimal crossing, every at-risk star who fell short instead reaches exactly 65; summing those games and dividing by the number of stars gives 0.67 games per star-season in the pre-rule seasons and 0.96 in the post-rule seasons. If every at-risk star plays every remaining game, the bound is 1.27 games pre-rule and 1.85 post-rule. The upper limit of the pooled qualifying-games interval is 6.52 games.

The window is a choice, and Appendix Table A9 varies it. Widening the window to slack 0 to 12 at game 62 raises the pre-rule at-risk count to 17.9 per season and the bounds to 0.75 and 2.05. Measuring slack at game 55 with the 0-to-12 window gives 16.8 at risk, 41% of stars, and bounds of 1.07 and 2.42; post-rule the widest construction reaches 3.79 under full play-through. Among the 19 stars per season with slack of 9 or more at game 62, one per season finished below 65 before the rule, adding 0.10 games per star-season to the bound. Every construction leaves the bound inside the estimated interval. The rule binds on a quarter to two-fifths of stars, and even a full response from all of them would move the mean by one to two games, below what a season-level comparison can detect. This is the arithmetic of Chetty et al. (2011) applied to a notch: the aggregate response is the product of the share of agents at the margin and the response of each.

#### Star Absences Are Spells, and Spells Rose for Everyone

Appendix Table A6 describes spells of ten or more consecutive missed games. Before the rule there were 127 star spells in 327 star-seasons, 0.39 per star-season, and 33% of star-seasons contained one; after the rule, 65 in 132, 0.49 per star-season, 39%. Long spells account for 10.0 missed games per star-season before the rule and 11.0 after. The rise is not specific to stars. The control went from 0.39 to 0.46 spells per player-season, 18% against the stars' 27%, and from 34% to 38% of player-seasons with a spell against the stars' 33% to 39%. By season, star spells per star-season were 0.58 in 2023, 0.33 in 2024, 0.43 in 2025, and 0.75 in 2026; the control's were 0.35, 0.38, 0.48, and 0.56. The rise is concentrated in 2025 and 2026 for both groups and coincides with the league-wide increase in injuries reported for 2024-25 (Sportico, 2025).

One difference remains. The share of star spells beginning in the late-season window rose from 27 of 127 to 20 of 65, 21% to 31%, Fisher *p* = .16, while the control's fell from 69 of 213 to 29 of 111, 32% to 26%, *p* = .25 (Appendix Table A12; Appendix Figure A2). The difference in shares, stars minus control and post minus pre, is 0.158 with a bootstrap 95% interval from -0.012 to 0.329. It is the one number in the article that points toward the union's claim that players are playing hurt to reach the line, and the discussion says what can and cannot be made of it.

#### Minutes: A Specification-Dependent Result

The model's fourth prediction is that the rule should lengthen short appearances. The evidence is mixed, and I report it that way. In levels, the share of star appearances lasting at least 20 minutes was 0.954 over 2015-2023 and 0.984 after the rule, against 0.911 and 0.912 for the control, a raw difference-in-differences of 2.9 points (Table 11). But the star share had been rising before the rule. It was 0.976 in 2023, and stars averaged 3.2 appearances under 20 minutes per season in 2015-2022, 1.4 in 2023, and 1.0 after the rule, against 5.8, 6.0, and 5.5 for the control. Against 2023 alone the raw difference-in-differences is 0.4 points, less than half an appearance per star-season.

The regression estimates divide along the same line. With player, season, and game-number fixed effects the pooled post-rule-by-star coefficient is 0.046 (SE 0.010), the event-study coefficients relative to 2023 are 0.043 (0.016), 0.040 (0.013), and 0.055 (0.016), and the pre-period is flat (Table 10). Without player fixed effects the pooled coefficient is 0.027 (0.014); it falls to 0.020 (0.015) when the sample is restricted to 2022 onward and to 0.021 (0.019) with a star-specific linear trend, and the event-study coefficients relative to 2023 are 0.015, -0.006, and 0.001. The difference is not produced by players who move between the star and control groups: among players who never switch, the estimates are 0.060 (0.016) with player effects and 0.028 (0.021) without.

The two sets of estimates answer different questions. The within-player estimates say that a given star's appearances were more likely to reach 20 minutes after the rule than in his own earlier seasons, relative to the same comparison for control players. The estimates without player effects say that the star group's share was already converging on one before the rule and did not break from that path when the rule arrived. I read the evidence as consistent with a small lengthening of marginal appearances, of the kind visible in the managed returns in Table 7, and not as a demonstrated effect of the rule. An earlier version of this test, which compared minute bins for stars with 0 to 3 games of slack against other stars, shows nothing once players returning from injury are removed (Appendix Table A16).

### Discussion

Across every test the notch model suggests on games, the rule left no detectable mark. There is no excess mass at 65. The stars nearest the line were no more likely to cross it. Star availability moved with the control, and the one season in which it appeared to move away was half composition and half a swing of a size the series had produced before and reversed after. Absence among stars who had just played did not rise in the states where the rule removed the incentive; it rose by two points in the state where the incentive remained. The reason is that the rule can matter only to the quarter to two-fifths of stars within reach of the line in the season's final weeks, and a complete response by all of them would add one to two games to the mean. The rest of star absence is injury, and injury is indifferent to award eligibility. This is the frictions reading of a null in Kleven (2016): not a zero elasticity, but a threshold placed where few agents can respond.

The design bounds effects; it does not estimate them precisely. A star-specific gain of one to three games per season is inside every interval and is the size the bounding argument allows. The design also cannot test the hypothesis that the rule causes injury by inducing players to play hurt. The late-onset shift in star spells moves that way, with an interval that reaches from -0.01 to 0.33. It rests on 20 post-rule spells; the rise in spells was league-wide, with 2025 and 2026 heavy injury seasons for both groups; and the source records no diagnosis, severity, or pre-injury workload. A test would need injury reports with diagnosis and severity, a measure of workload before onset, and a comparison of onset hazards between at-risk stars and stars far from the line at the same point in the season, over enough seasons for the injury cycle to average out. I report the number so that it is not left unaddressed, and I do not claim to have tested it. Both control groups are partially treated; if All-Defensive, Most Improved, and Sixth Man candidates responded, the estimates are biased toward zero, though the bounding argument does not depend on a control group. Three post-rule seasons is a short window, and the waivers granted in 2026 mean the notch is administered with discretion at the margin.

For the league, award eligibility is the wrong lever for the availability problem as it exists. The players whose absences drive the aggregate are injured, and the players who are healthy and choosing are few and already playing most nights. A rule that binds on ten to eighteen players a season, each of whom can add a few games, has a ceiling of one to two games per star, below the noise in a season's schedule. For the study of notches, the case is a useful negative: where the population at the margin is small, the absence of bunching is evidence that the estimator has nothing to work with, and reporting the size of that population and the bound it implies alongside the null, in the partially identified spirit of Bertanha et al. (2023), is the appropriate presentation. The cheapest adjacent margin, minutes, is where a response would be expected first, and the evidence there does not survive the removal of player fixed effects. For researchers using ESPN box scores, the practical result is that the source carries the active list, and absence, rest, and availability must be measured on the schedule.

## References

Allen, E. J., Dechow, P. M., Pope, D. G., & Wu, G. (2017). Reference-dependent preferences: Evidence from marathon runners. *Management Science*, *63*(6), 1657-1672. https://doi.org/10.1287/mnsc.2015.2417

Associated Press. (2026, April). Wembanyama gets to 65 games and award eligibility. Jokic still a game away from that mark. *FOX Sports*. https://www.foxsports.com/articles/nba/wembanyama-gets-to-65-games-and-award-eligibility-jokic-still-a-game-away-from-that-mark

Bergé, L. (2018). *Efficient estimation of maximum likelihood models with multiple fixed-effects: The R package FENmlm* (CREA Discussion Paper No. 13). University of Luxembourg.

Berri, D. J., & Krautmann, A. C. (2006). Shirking on the court: Testing for the incentive effects of guaranteed pay. *Economic Inquiry*, *44*(3), 536-546. https://doi.org/10.1093/ei/cbj033

Bertanha, M., McCallum, A. H., & Seegert, N. (2023). Better bunching, nicer notching. *Journal of Econometrics*, *237*(2), Article 105512. https://doi.org/10.1016/j.jeconom.2023.105512

Bertrand, M., Duflo, E., & Mullainathan, S. (2004). How much should we trust differences-in-differences estimates? *Quarterly Journal of Economics*, *119*(1), 249-275. https://doi.org/10.1162/003355304772839588

Bontemps, T. (2020, December 7). NBA relaxes resting policies for non-nationally televised games. *ESPN*. https://www.espn.com/nba/story/_/id/30471327/

CBS Sports. (2019, November). NBA says teams using load management designation to sit players will be in violation of league resting policy. https://www.cbssports.com/nba/news/nba-says-teams-using-load-management-designation-to-sit-players-will-be-in-violation-of-league-resting-policy

CBS Sports. (2024, September 25). Pirates cut Rowdy Tellez four plate appearances shy of $200K bonus; GM claims money played "zero factor." https://www.cbssports.com/mlb/news/pirates-cut-rowdy-tellez-four-plate-appearances-shy-of-200k-bonus-gm-claims-money-played-zero-factor

Chan, H. F., Frey, B. S., Gallus, J., & Torgler, B. (2014). Academic honors and performance. *Labour Economics*, *31*, 188-204. https://doi.org/10.1016/j.labeco.2014.05.005

Chetty, R., Friedman, J. N., Olsen, T., & Pistaferri, L. (2011). Adjustment costs, firm responses, and micro vs. macro labor supply elasticities: Evidence from Danish tax records. *Quarterly Journal of Economics*, *126*(2), 749-804. https://doi.org/10.1093/qje/qjr013

Ehrenberg, R. G., & Bognanno, M. L. (1990). Do tournaments have incentive effects? *Journal of Political Economy*, *98*(6), 1307-1324. https://doi.org/10.1086/261736

ESPN. (2026, April 16). Luka Doncic, Cade Cunningham awards eligible; Edwards denied. https://www.espn.com/nba/story/_/id/48504211/

Esteves, P. T., Mikolajec, K., Schelling, X., & Sampaio, J. (2021). Basketball performance is affected by the schedule congestion: NBA back-to-backs under the microscope. *European Journal of Sport Science*, *21*(1), 26-35. https://doi.org/10.1080/17461391.2020.1736179

Frey, B. S., & Gallus, J. (2017). *Honours versus money: The economics of awards*. Oxford University Press. https://doi.org/10.1093/oso/9780198798507.001.0001

Fumarco, L., Longley, N., Palermo, A., & Rossi, G. (2024). Strategic behaviours in a labour market with mobility-restricting contractual provisions: Evidence from the National Hockey League. *Oxford Economic Papers*, *76*(4), 1189-1203. https://doi.org/10.1093/oep/gpae010

Gilani, S. (2021). *hoopR: The SportsDataverse's R package for men's basketball data* [Computer software]. https://doi.org/10.32614/CRAN.package.hoopR

Hausman, J. A., & Leonard, G. K. (1997). Superstars in the National Basketball Association: Economic value and policy. *Journal of Labor Economics*, *15*(4), 586-624. https://doi.org/10.1086/209839

Hoops Rumors. (2024, January 30). Minimum game requirement for awards looms large for super-max candidates. https://www.hoopsrumors.com/2024/01/minimum-game-requirement-for-awards-looms-large-for-super-max-candidates.html

Kahn, L. M. (2000). The sports business as a labor market laboratory. *Journal of Economic Perspectives*, *14*(3), 75-94. https://doi.org/10.1257/jep.14.3.75

Kaplan, S. M. (2022). Putting a price on popularity: Evidence from superstars in the National Basketball Association. *Economic Inquiry*, *60*(3), 1357-1381. https://doi.org/10.1111/ecin.13065

Kaplan, S., Ramamoorthy, V., Gupte, C., Sagar, A., Premkumar, D., Wilbur, J., & Zilberman, D. (2019). *The economic impact of NBA superstars: Evidence from missed games using ticket microdata from a secondary marketplace* [Conference paper]. MIT Sloan Sports Analytics Conference, Boston, MA, United States.

Kleven, H. J. (2016). Bunching. *Annual Review of Economics*, *8*, 435-464. https://doi.org/10.1146/annurev-economics-080315-015234

Kleven, H. J., & Waseem, M. (2013). Using notches to uncover optimization frictions and structural elasticities: Theory and evidence from Pakistan. *Quarterly Journal of Economics*, *128*(2), 669-723. https://doi.org/10.1093/qje/qjt004

Kosfeld, M., & Neckermann, S. (2011). Getting more work for nothing? Symbolic awards and worker performance. *American Economic Journal: Microeconomics*, *3*(3), 86-99. https://doi.org/10.1257/mic.3.3.86

Lazear, E. P., & Rosen, S. (1981). Rank-order tournaments as optimum labor contracts. *Journal of Political Economy*, *89*(5), 841-864. https://www.jstor.org/stable/1830810

Mack, C. D., Herzog, M. M., DiFiori, J. P., Meisel, P. L., & Dreyer, N. A. (2018). A second look at NBA game schedules: Response to Teramoto et al. *Journal of Science and Medicine in Sport*, *21*(3), 228-229. https://doi.org/10.1016/j.jsams.2017.07.023

Marks, B. (2023, October 10). Answering the big questions about the NBA's new rules on resting stars. *ESPN*. https://www.espn.com/nba/story/_/id/38386013/

Nakamura-Sakai, S., Forastiere, L., & Macdonald, B. (2024). *Estimating the age-conditioned average treatment effects curves: An application for assessing load-management strategies in the NBA* (arXiv:2402.12400). arXiv. https://arxiv.org/abs/2402.12400

National Basketball Association. (2023a, September 13). *NBA Board of Governors approves new Player Participation Policy* [Press release]. https://pr.nba.com/nba-board-of-governors-approves-player-participation-policy

National Basketball Association. (2023b, September). *Adam Silver discusses new policy as load management goes "too far."* NBA.com. https://www.nba.com/news/adam-silver-load-management-bog-news-conference-2023

NBC Sports. (2020, December 8). NBA memo warns of large fines for resting players for nationally televised games. https://www.nbcsports.com/nba/news/nba-memo-warns-of-large-fines-for-resting-players-for-nationally-televised-games

Neckermann, S., Cueni, R., & Frey, B. S. (2014). Awards at work. *Labour Economics*, *31*, 205-217. https://doi.org/10.1016/j.labeco.2014.04.002

Novy-Williams, E. (2023, May 10). Ja Morant loses $39M from All-NBA vote, while Jaylen Brown scores big. *Sportico*. https://www.sportico.com/leagues/basketball/2023/nba-awards-2023-ja-morant-jaylen-brown-1234722369/

Novy-Williams, E., & Impey, S. (2024, April). NBA awards, load management policy reduced missed games by stars. *Sportico*. https://www.sportico.com/leagues/basketball/2024/nba-awards-load-management-adam-silver-1234775529/

Owsik, C., & Tan, K. (2026). The contract year phenomenon: Investigating the effect of contract uncertainty on NBA player performance. *Applied Economics Letters*. Advance online publication. https://doi.org/10.1080/13504851.2026.2629455

Pelton, K., & Arnovitz, K. (2019, November 13). NBA load management: What we know and don't know. *ESPN*. https://www.espn.com/nba/story/_/id/28066201/

Pope, D., & Simonsohn, U. (2011). Round numbers as goals: Evidence from baseball, SAT takers, and the lab. *Psychological Science*, *22*(1), 71-79. https://doi.org/10.1177/0956797610391098

Price, J., Soebbing, B. P., Berri, D., & Humphreys, B. R. (2010). Tournament incentives, league policy, and NBA team performance revisited. *Journal of Sports Economics*, *11*(2), 117-135. https://doi.org/10.1177/1527002510363103

Rosen, S. (1981). The economics of superstars. *American Economic Review*, *71*(5), 845-858. https://www.jstor.org/stable/1803469

Saez, E. (2010). Do taxpayers bunch at kink points? *American Economic Journal: Economic Policy*, *2*(3), 180-212. https://doi.org/10.1257/pol.2.3.180

Sportico. (2025, May 21). NBA policies curb star absences amid spike in overall injuries. https://www.sportico.com/leagues/basketball/2025/nba-injuries-load-management-data-participation-1234849899/

Sports Illustrated. (2026). How NBA Cup rule quirk benefits Spurs star Victor Wembanyama. https://www.si.com/nba/spurs/onsi/news/how-nba-cup-rule-quirk-benefits-spurs-star-victor-wembanyama

Stiroh, K. J. (2007). Playing for keeps: Pay and performance in the NBA. *Economic Inquiry*, *45*(1), 145-161. https://doi.org/10.1111/j.1465-7295.2006.00004.x

Taylor, B. A., & Trogdon, J. G. (2002). Losing to win: Tournament incentives in the National Basketball Association. *Journal of Labor Economics*, *20*(1), 23-41. https://doi.org/10.1086/323930

Teramoto, M., Cross, C. L., Cushman, D. M., Maak, T. G., Petron, D. J., & Willick, S. E. (2017). Game injuries in relation to game schedules in the National Basketball Association. *Journal of Science and Medicine in Sport*, *20*(3), 230-235. https://doi.org/10.1016/j.jsams.2016.08.020

Toporek, B. (2026, April 18). "Extraordinary circumstances" further muddle NBA's 65-game awards rule. *Forbes*. https://www.forbes.com/sites/bryantoporek/2026/04/18/

Torres-Ronda, L., Gámez, I., Robertson, S., & Fernández, J. (2022). Epidemiology and injury trends in the National Basketball Association: Pre- and per-COVID-19 (2017-2021). *PLOS ONE*, *17*(2), Article e0263354. https://doi.org/10.1371/journal.pone.0263354

White, M. H., II, & Sheldon, K. M. (2014). The contract year syndrome in the NBA and MLB: A classic undermining pattern. *Motivation and Emotion*, *38*, 196-205. https://doi.org/10.1007/s11031-013-9389-7

Wojnarowski, A., Marks, B., & Zillgitt, J. (2023, September 13). NBA board of governors approves tougher rest rule, penalties. *ESPN*. https://www.espn.com/nba/story/_/id/38392750/

## Tables

Table 1. Sample by season (tab1_sample)
Table 2. ESPN box-score coverage of absences (tab2_source_coverage)
Table 3. Availability event study (tab3a_availability_event_study)
Table 4. Pooled post-rule differences in availability (tab3b_availability_pooled)
Table 5. Excess mass at 65 (tab4b_bunching_excess_mass)
Table 6. The maximal-effect bound (tab5c_bound)
Table 7. Healthy at-risk stars, post-rule (tab5d_case_table)
Table 8. Absence by eligibility state (tab6a_absence_by_state)
Table 9. Star-specific change in absence at two policy breaks (tab6c_absence_star_vs_nonstar)
Table 10. Share of appearances of 20 or more minutes, event studies (tabA12_share20_event_study)
Table 11. Share of appearances of 20 or more minutes, raw comparisons and specifications (tabA15_share20_specs)

## Figures

Figure 1. Policy timeline (fig1_policy_timeline)
Figure 2. Qualifying games of stars before and after the rule (fig2_bunching_histogram)
Figure 3. Availability event study (fig3_availability_event_study)
Figure 4. Absence by eligibility state (fig4_absence_by_state)
Figure 5. Absence, stars versus control (fig5_absence_stars_vs_nonstars)

## Appendix A. Additional Tables and Figures

Table A1 tab4a_bunching_bins; A2 tab5a_at_risk_reach; A3 tab5b_at_risk_regressions; A4 tab6b_absence_state_regressions; A5 tabA1_absence_event_study; A6 tabA3_long_absences; A7 tabA8_composition_2024; A8 tabA9_cohort_pairs; A9 tabA10_bound_windows; A10 tabA11_exact65; A11 tabA11b_exact65_distribution; A12 tabA13_late_onset; A13 tabA14_bbr_boxscore_check; A14 tabA5_bbr_validation; A15 tabA7_exhibition_correction; A16 tabA2_minute_bins; A17 tabA4_absence_reasons; A18 tabA6_stars_no_appearance; A19 tabA16_rowsonly_raw. Figure A1 figA1_at_risk_by_season; A2 figA2_absence_timing; A3 figA3_absence_by_state_by_season.
