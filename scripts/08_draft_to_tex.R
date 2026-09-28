# =============================================================================
# 08_draft_to_tex.R
#
# Build the LaTeX version of the draft from the Markdown source so the two stay
# in sync. Reads docs/draft/draft_v3.md, writes docs/draft/draft_v3.tex, which
# \input{}s the kableExtra tables in results/tables/paper and includes the
# figures in results/figures/paper. Compile from docs/draft with pdflatex (twice).
# =============================================================================
suppressPackageStartupMessages(library(tidyverse))
PROJECT_ROOT <- "/Users/maddockl/nba-65-game-rule"; setwd(PROJECT_ROOT)
MD  <- "docs/draft/draft_v3.md"; TEX <- "docs/draft/draft_v3.tex"
TAB <- "../../results/tables/paper"; FIG <- "../../results/figures/paper"
check <- function(cond, msg) { if (!isTRUE(cond)) stop("CHECK FAILED: ", msg, call. = FALSE); cat("  ok:", msg, "\n") }

lines <- read_lines(MD)

# ---- inline conversion -------------------------------------------------------
esc_text <- function(x) {
  x <- str_replace_all(x, fixed("\\"), "\\textbackslash{}")
  x <- str_replace_all(x, fixed("&"), "\\&")
  x <- str_replace_all(x, fixed("%"), "\\%")
  x <- str_replace_all(x, fixed("#"), "\\#")
  x <- str_replace_all(x, fixed("_"), "\\_")
  x <- str_replace_all(x, fixed("$"), "\\$")
  x <- str_replace_all(x, fixed("~"), "\\textasciitilde{}")
  x <- str_replace_all(x, fixed("^"), "\\textasciicircum{}")
  x <- str_replace_all(x, "\"([^\"]*)\"", "``\\1''")
  x
}
# Protect math and URLs, escape the rest, then apply markdown emphasis
inline <- function(s) {
  # split into math segments ($...$), URLs, and text
  pattern <- "\\$[^$]+\\$|https?://[^\\s)\\]]+"
  locs <- str_locate_all(s, pattern)[[1]]
  if (nrow(locs) == 0) return(md_emph(esc_text(s)))
  out <- ""; pos <- 1
  for (i in seq_len(nrow(locs))) {
    if (locs[i, 1] > pos) out <- paste0(out, md_emph(esc_text(str_sub(s, pos, locs[i, 1] - 1))))
    tok <- str_sub(s, locs[i, 1], locs[i, 2])
    tok <- if (str_starts(tok, "\\$")) tok else paste0("\\url{", str_remove(tok, "[.,;]$"), "}", str_extract(tok, "[.,;]$") %>% replace_na(""))
    out <- paste0(out, tok); pos <- locs[i, 2] + 1
  }
  if (pos <= nchar(s)) out <- paste0(out, md_emph(esc_text(str_sub(s, pos))))
  out
}
md_emph <- function(x) {
  x <- str_replace_all(x, "\\*\\*([^*]+)\\*\\*", "\\\\textbf{\\1}")
  x <- str_replace_all(x, "\\*([^*]+)\\*", "\\\\emph{\\1}")
  x <- str_replace_all(x, "`([^`]+)`", "\\\\texttt{\\1}")
  # bracketed table/file citations -> small typewriter, as in the Markdown
  x <- str_replace_all(x, "\\[((?:tab|fig|waiver|rest_|qg_|absences|at_risk|minutes)[^\\]]*)\\]", "{\\\\small\\\\texttt{[\\1]}}")
  x
}

# ---- footnotes: collect definitions, splice into references --------------------
fn_def <- str_match(lines, "^\\[\\^([a-z]+)\\]: (.*)$")
footnotes <- set_names(fn_def[, 3][!is.na(fn_def[, 1])], fn_def[, 2][!is.na(fn_def[, 1])])
lines <- lines[is.na(fn_def[, 1])]
# footnote markers are replaced by plain tokens before escaping, then expanded afterwards
mark_fn <- function(s) str_replace_all(s, "\\[\\^([a-z]+)\\]", "FNTOKEN\\1END")
splice_fn <- function(s) { for (k in names(footnotes)) s <- str_replace(s, paste0("FNTOKEN", k, "END"), function(m) paste0("\\footnote{", inline(footnotes[[k]]), "}")); s }

# ---- header ----------------------------------------------------------------------
title  <- str_remove(lines[str_detect(lines, "^# ")][1], "^# ")
i_title <- which(str_detect(lines, "^# "))[1]
author <- lines[i_title + 2]; affil <- lines[i_title + 3]
draft_note <- lines[str_detect(lines, "^\\*Draft v")][1] %>% str_remove_all("^\\*|\\*$")

figure_captions <- c(
  fig1_policy_timeline = "Policy timeline: the 2017 resting policy, the 2019 and 2020 memos, the 2023 CBA and Player Participation Policy, and the 2026 waivers. Shaded bars mark the regimes; 2019-20 and 2020-21 are excluded from estimation.",
  fig2_bunching_histogram = "Qualifying games of star player-seasons before and after the 65-game rule. Dashed line: 65-game threshold. Red step in the lower panel: pre-rule distribution scaled to the post-rule count (the counterfactual).",
  fig3_availability_event_study = "Star availability relative to high-minute non-stars defined on prior-season status, by season, reference 2023. Player and season fixed effects; 95 percent intervals clustered by player. Blue band: pooled post-rule estimate with its 95 percent interval.",
  fig4_absence_by_state = "Late-season absence of stars who played the previous game, by eligibility state, before and after the rule, with 95 percent binomial intervals.",
  fig5_absence_stars_vs_nonstars = "Late-season absence after playing the previous game: stars and the control group. Upper panel: raw rates. Lower panel: star-by-season coefficients relative to 2023 with player, season and game-number fixed effects.",
  figA1_at_risk_by_season = "Stars at risk at team game 62 (slack 0-8), by season; black: at risk and did not reach 65; number above bar: stars that season.",
  figA2_absence_timing = "Team game at which spells of 10 or more missed games began, per 100 player-seasons, stars and control, before and after the rule.",
  figA3_absence_by_state_by_season = "Late-season absence of stars who played the previous game, by eligibility state and season; point size is the number of player-games in the cell."
)
main_tables <- c("tab1_sample", "tab2_source_coverage", "tab3a_availability_event_study", "tab3b_availability_pooled", "tab4a_bunching_bins",
                 "tab4b_bunching_excess_mass", "tab5a_at_risk_reach", "tab5b_at_risk_regressions", "tab5c_bound", "tab5d_case_table",
                 "tab6a_absence_by_state", "tab6b_absence_state_regressions", "tab6c_absence_star_vs_nonstar")
app_tables <- c("tabA1_absence_event_study", "tabA2_minute_bins", "tabA3_long_absences", "tabA4_absence_reasons", "tabA5_bbr_validation",
                "tabA6_stars_no_appearance", "tabA7_exhibition_correction", "tabA8_composition_2024", "tabA9_cohort_pairs", "tabA10_bound_windows",
                "tabA11_exact65", "tabA11b_exact65_distribution", "tabA12_share20_event_study", "tabA13_late_onset", "tabA14_bbr_boxscore_check")
check(all(file.exists(file.path("results/tables/paper", paste0(c(main_tables, app_tables), ".tex")))), "all table .tex files exist")
check(all(file.exists(file.path("results/figures/paper", paste0(names(figure_captions), ".png")))), "all figure files exist")

# ---- body ------------------------------------------------------------------------
body <- c()
in_refs <- FALSE; in_list <- FALSE; in_quote <- FALSE
close_list <- function() { if (in_list) { body <<- c(body, "\\end{enumerate}"); in_list <<- FALSE } }
skip_until_abstract_done <- FALSE
i <- i_title + 4
while (i <= length(lines)) {
  l <- lines[i]
  if (str_detect(l, "^\\*Draft v")) { i <- i + 1; next }
  if (str_detect(l, "^## Abstract")) {
    j <- i + 1; abs_par <- c(); jel <- c()
    while (j <= length(lines) && !str_detect(lines[j], "^## ")) {
      if (str_detect(lines[j], "^\\*JEL codes:\\*|^\\*Keywords:\\*")) jel <- c(jel, lines[j]) else if (nzchar(lines[j])) abs_par <- c(abs_par, lines[j])
      j <- j + 1
    }
    body <- c(body, "\\begin{abstract}", inline(paste(abs_par, collapse = " ")), "\\end{abstract}", "",
              "\\noindent " %>% paste0(paste(map_chr(jel, ~ inline(.x)), collapse = "\\\\ ")), "", "\\clearpage", "")
    i <- j; next
  }
  if (str_detect(l, "^## References")) { close_list(); in_refs <- TRUE; body <- c(body, "\\clearpage", "\\section*{References}", "\\begingroup\\sloppy\\small", "\\begin{hangparas}{1.5em}{1}"); i <- i + 1; next }
  if (str_detect(l, "^---$")) { if (in_refs) { body <- c(body, "\\end{hangparas}", "\\endgroup"); in_refs <- FALSE }; i <- i + 1; next }
  if (str_detect(l, "^### ")) { close_list(); h <- str_remove(l, "^### ") %>% str_remove("^[0-9]+\\.[0-9]+ "); body <- c(body, "", paste0("\\subsection*{", inline(h), "}"), ""); i <- i + 1; next }
  if (str_detect(l, "^## ")) { close_list(); h <- str_remove(l, "^## ") %>% str_remove("^[0-9]+\\. "); body <- c(body, "", paste0("\\section{", inline(h), "}"), ""); i <- i + 1; next }
  if (str_detect(l, "^> ")) { body <- c(body, "\\begin{quote}", inline(str_remove(l, "^> ")), "\\end{quote}", ""); i <- i + 1; next }
  if (str_detect(l, "^[0-9]+\\. ")) { if (!in_list) { body <- c(body, "\\begin{enumerate}"); in_list <- TRUE }; body <- c(body, paste0("\\item ", inline(str_remove(l, "^[0-9]+\\. ")))); i <- i + 1; next }
  if (!nzchar(l)) { close_list(); body <- c(body, ""); i <- i + 1; next }
  body <- c(body, splice_fn(inline(mark_fn(l))))
  i <- i + 1
}
close_list(); if (in_refs) body <- c(body, "\\end{hangparas}", "\\endgroup")

# ---- figures and tables ------------------------------------------------------------
fig_block <- function(name, num) c("\\begin{figure}[p]", "\\centering", paste0("\\includegraphics[width=\\linewidth]{", FIG, "/", name, ".png}"),
                                    paste0("\\caption{", figure_captions[[name]], "}"), paste0("\\label{fig:", name, "}"), "\\end{figure}", "")
figs_main <- unlist(map(names(figure_captions)[1:5], fig_block))
figs_app  <- unlist(map(names(figure_captions)[6:8], fig_block))
tabs_main <- unlist(map(main_tables, ~ c(paste0("\\input{", TAB, "/", .x, ".tex}"), "")))
tabs_app  <- unlist(map(app_tables,  ~ c(paste0("\\input{", TAB, "/", .x, ".tex}"), "")))

preamble <- c(
  "% Built by scripts/08_draft_to_tex.R from docs/draft/draft_v3.md. Edit the Markdown, then rerun the script.",
  "% Compile from docs/draft: pdflatex draft_v3.tex (twice). Tables are \\input from results/tables/paper; figures from results/figures/paper.",
  "% Table numbering in this file is sequential; the Markdown labels tables by section (e.g. Table 6a). The bracketed file names in the text identify each table.",
  "\\documentclass[11pt]{article}",
  "\\usepackage[margin=1in]{geometry}",
  "\\usepackage{amsmath,amssymb}",
  "\\usepackage{booktabs,threeparttable,graphicx,float,longtable,array}",
  "\\usepackage{hanging}",
  "\\usepackage[hidelinks]{hyperref}",
  "\\usepackage{xurl}",
  "\\emergencystretch 3em",
  "\\usepackage{setspace}\\onehalfspacing",
  "\\usepackage[T1]{fontenc}\\usepackage[utf8]{inputenc}\\usepackage{lmodern}",
  "\\setcounter{secnumdepth}{1}",
  paste0("\\title{", inline(title), "}"),
  paste0("\\author{", inline(author), "\\\\ \\small ", inline(affil), "}"),
  paste0("\\date{", inline(draft_note), "}"),
  "\\begin{document}", "\\maketitle", ""
)
tex <- c(preamble, body, "", "\\clearpage", "\\section*{Figures}", figs_main, "\\clearpage", "\\section*{Tables}", tabs_main,
         "\\clearpage", "\\appendix", "\\section*{Appendix figures}", figs_app, "\\clearpage", "\\section*{Appendix tables}", tabs_app, "\\end{document}")
write_lines(tex, TEX)
cat("  wrote", TEX, "with", length(tex), "lines\n")
check(sum(str_count(tex, fixed("\\footnote{"))) == length(footnotes), "every Markdown footnote spliced into the LaTeX")
cat("Done.\n")
