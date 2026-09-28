# =============================================================================
# 09_jse_to_tex.R
#
# Build the Journal of Sports Economics submission version (APA 7 layout) from
# docs/draft/draft_v4_jse.md: title page, abstract page with keywords, text with
# APA heading levels, endnotes ("Footnotes"), references, tables, figures, and a
# lettered appendix. 12-pt Times, double spacing, 1-inch margins, page numbers.
# Compile from docs/draft with pdflatex (twice).
# =============================================================================
suppressPackageStartupMessages(library(tidyverse))
PROJECT_ROOT <- "/Users/maddockl/nba-65-game-rule"; setwd(PROJECT_ROOT)
MD  <- "docs/draft/draft_v4_jse.md"; TEX <- "docs/draft/draft_v4_jse.tex"
TAB <- "../../results/tables/paper"; FIG <- "../../results/figures/paper"
check <- function(cond, msg) { if (!isTRUE(cond)) stop("CHECK FAILED: ", msg, call. = FALSE); cat("  ok:", msg, "\n") }
lines <- read_lines(MD)

esc_text <- function(x) {
  x <- str_replace_all(x, fixed("\\"), "\\textbackslash{}")
  x <- str_replace_all(x, fixed("&"), "\\&"); x <- str_replace_all(x, fixed("%"), "\\%"); x <- str_replace_all(x, fixed("#"), "\\#")
  x <- str_replace_all(x, fixed("_"), "\\_"); x <- str_replace_all(x, fixed("$"), "\\$"); x <- str_replace_all(x, fixed("~"), "\\textasciitilde{}")
  x <- str_replace_all(x, fixed("^"), "\\textasciicircum{}")
  x <- str_replace_all(x, "\"([^\"]*)\"", "``\\1''")
  x
}
md_emph <- function(x) {
  x <- str_replace_all(x, "\\*\\*([^*]+)\\*\\*", "\\\\textbf{\\1}")
  x <- str_replace_all(x, "\\*([^*]+)\\*", "\\\\emph{\\1}")
  x <- str_replace_all(x, "`([^`]+)`", "\\\\texttt{\\1}")
  x
}
inline <- function(s) {
  pattern <- "\\$[^$]+\\$|https?://[^\\s)\\]]+"
  locs <- str_locate_all(s, pattern)[[1]]
  if (nrow(locs) == 0) return(md_emph(esc_text(s)))
  out <- ""; pos <- 1
  for (i in seq_len(nrow(locs))) {
    if (locs[i, 1] > pos) out <- paste0(out, md_emph(esc_text(str_sub(s, pos, locs[i, 1] - 1))))
    tok <- str_sub(s, locs[i, 1], locs[i, 2])
    if (!str_starts(tok, "\\$")) { trail <- str_extract(tok, "[.,;]$") %>% replace_na(""); tok <- paste0("\\url{", str_remove(tok, "[.,;]$"), "}", trail) }
    out <- paste0(out, tok); pos <- locs[i, 2] + 1
  }
  if (pos <= nchar(s)) out <- paste0(out, md_emph(esc_text(str_sub(s, pos))))
  out
}
fn_def <- str_match(lines, "^\\[\\^([a-z]+)\\]: (.*)$")
footnotes <- set_names(fn_def[, 3][!is.na(fn_def[, 1])], fn_def[, 2][!is.na(fn_def[, 1])])
lines <- lines[is.na(fn_def[, 1])]
mark_fn <- function(s) str_replace_all(s, "\\[\\^([a-z]+)\\]", "FNTOKEN\\1END")
splice_fn <- function(s) { for (k in names(footnotes)) s <- str_replace(s, paste0("FNTOKEN", k, "END"), function(m) paste0("\\endnote{", inline(footnotes[[k]]), "}")); s }

# ---- sections of the Markdown -------------------------------------------------------
title <- str_remove(lines[str_detect(lines, "^# ")][1], "^# ")
sec_idx <- which(str_detect(lines, "^## "))
sec_name <- str_remove(lines[sec_idx], "^## ")
get_sec <- function(name) { i <- which(sec_name == name); if (!length(i)) return(character(0)); a <- sec_idx[i] + 1; b <- if (i < length(sec_idx)) sec_idx[i + 1] - 1 else length(lines); lines[a:b] }
tp <- get_sec("Title Page") %>% keep(nzchar)
field <- function(k) { v <- tp[str_starts(tp, paste0(k, ":"))]; if (length(v)) str_squish(str_remove(v[1], paste0("^", k, ":"))) else "" }
abs_lines <- get_sec("Abstract") %>% keep(nzchar)
keywords <- abs_lines[str_starts(abs_lines, "\\*Keywords:\\*")] %>% str_remove("^\\*Keywords:\\*\\s*")
abstract <- abs_lines[!str_starts(abs_lines, "\\*Keywords:\\*")] %>% paste(collapse = " ")
check(str_count(abstract, "\\S+") <= 150, paste("abstract is at most 150 words (", str_count(abstract, "\\S+"), ")"))
check((str_count(keywords, ",") + 1) %in% 4:5, "four or five keywords")
text_lines <- get_sec("Text"); ref_lines <- get_sec("References") %>% keep(nzchar)

# ---- body conversion --------------------------------------------------------------------
body <- c()
for (l in text_lines) {
  if (str_detect(l, "^##### ")) { body <- c(body, paste0("\\lthree{", inline(str_remove(l, "^##### ") %>% str_remove("\\.$")), "}")); next }
  if (str_detect(l, "^#### ")) { body <- c(body, "", paste0("\\ltwo{", inline(str_remove(l, "^#### ")), "}"), ""); next }
  if (str_detect(l, "^### ")) { body <- c(body, "", paste0("\\lone{", inline(str_remove(l, "^### ")), "}"), ""); next }
  if (str_detect(l, "^> ")) { body <- c(body, "\\begin{quote}\\singlespacing", inline(str_remove(l, "^> ")), "\\end{quote}", ""); next }
  if (!nzchar(l)) { body <- c(body, ""); next }
  body <- c(body, splice_fn(inline(mark_fn(l))))
}
refs <- unlist(map(ref_lines, ~ c(inline(.x), "")))

# ---- citation / reference cross-check (APA: every citation listed, every entry cited) ----
text_all <- paste(c(text_lines, unname(footnotes)), collapse = " ")
ref_keys <- str_match(ref_lines, "^([A-Z][^(]*?)\\s*\\((\\d{4}[a-z]?)")[, 2:3]
first_author <- str_extract(ref_keys[, 1], "^[^,]+") %>% str_squish()
first_author <- if_else(str_detect(first_author, "&"), str_extract(ref_keys[, 1], "^[A-Za-z' .-]+") %>% str_squish(), first_author) %>% str_remove("\\.$") %>% str_squish()
cited <- map2_lgl(first_author, ref_keys[, 2], ~ str_detect(text_all, fixed(.x)) && str_detect(text_all, fixed(str_sub(.y, 1, 4))))
if (any(!cited)) cat("  entries whose first author or year was not found in the text:", paste(first_author[!cited], ref_keys[!cited, 2]), "\n")
check(all(cited), "every reference entry has its first author and year in the text")
years_in_text <- str_extract_all(text_all, "\\(([^()]*?\\d{4}[a-z]?)\\)")[[1]]
cat("  parenthetical citations found in text:", length(years_in_text), "; reference entries:", nrow(ref_keys), "\n")

# ---- tables and figures ---------------------------------------------------------------------
main_tables <- c("tab1_sample", "tab2_source_coverage", "tab3a_availability_event_study", "tab3b_availability_pooled", "tab4b_bunching_excess_mass",
                 "tab5c_bound", "tab5d_case_table", "tab6a_absence_by_state", "tab6c_absence_star_vs_nonstar", "tabA12_share20_event_study", "tabA15_share20_specs")
app_tables  <- c("tab4a_bunching_bins", "tab5a_at_risk_reach", "tab5b_at_risk_regressions", "tab6b_absence_state_regressions", "tabA1_absence_event_study",
                 "tabA3_long_absences", "tabA8_composition_2024", "tabA9_cohort_pairs", "tabA10_bound_windows", "tabA11_exact65", "tabA11b_exact65_distribution",
                 "tabA13_late_onset", "tabA14_bbr_boxscore_check", "tabA5_bbr_validation", "tabA7_exhibition_correction", "tabA2_minute_bins",
                 "tabA4_absence_reasons", "tabA6_stars_no_appearance", "tabA16_rowsonly_raw")
figure_captions <- c(
  fig1_policy_timeline = "Policy timeline. Shaded bars mark the regimes; 2019-20 and 2020-21 are excluded from estimation.",
  fig2_bunching_histogram = "Qualifying games of star player-seasons before and after the 65-game rule. Dashed line: 65-game threshold. Red step in the lower panel: pre-rule distribution scaled to the post-rule count (the counterfactual).",
  fig3_availability_event_study = "Star availability relative to high-minute non-stars defined on prior-season status, by season, reference 2023. Player and season fixed effects; 95\\% intervals clustered by player. Blue band: pooled post-rule estimate with its 95\\% interval.",
  fig4_absence_by_state = "Late-season absence of stars who played the previous game, by eligibility state, before and after the rule, with 95\\% binomial intervals.",
  fig5_absence_stars_vs_nonstars = "Late-season absence after playing the previous game: stars and the control group. Upper panel: raw rates. Lower panel: star-by-season coefficients relative to 2023 with player, season and game-number fixed effects.",
  figA1_at_risk_by_season = "Stars at risk at team game 62 (slack 0-8), by season; black: at risk and did not reach 65; number above bar: stars that season.",
  figA2_absence_timing = "Team game at which spells of 10 or more missed games began, per 100 player-seasons, stars and control, before and after the rule.",
  figA3_absence_by_state_by_season = "Late-season absence of stars who played the previous game, by eligibility state and season; point size is the number of player-games in the cell.")
check(all(file.exists(file.path("results/tables/paper", paste0(c(main_tables, app_tables), ".tex")))), "all table .tex files exist")
check(all(file.exists(file.path("results/figures/paper", paste0(names(figure_captions), ".png")))), "all figure files exist")
# the text refers to tables and figures by number; confirm every referenced number exists in the ordering
tab_refs <- as.integer(unique(str_extract_all(text_all, "(?<=Table )\\d+")[[1]])); fig_refs <- as.integer(unique(str_extract_all(text_all, "(?<=Figure )\\d+")[[1]]))
apt_refs <- as.integer(unique(str_extract_all(text_all, "(?<=Table A)\\d+")[[1]])); apf_refs <- as.integer(unique(str_extract_all(text_all, "(?<=Figure A)\\d+")[[1]]))
check(all(tab_refs <= length(main_tables)) && all(fig_refs <= 5) && all(apt_refs <= length(app_tables)) && all(apf_refs <= 3), "every table and figure number cited in the text exists")
check(setequal(tab_refs, seq_along(main_tables)), "every main table is cited in the text")
fig_block <- function(name) c("\\begin{figure}[p]", "\\centering", paste0("\\includegraphics[width=\\linewidth]{", FIG, "/", name, ".png}"),
                              paste0("\\caption{", figure_captions[[name]], "}"), "\\end{figure}", "\\clearpage")
tab_block <- function(name) c(paste0("\\input{", TAB, "/", name, ".tex}"), "\\clearpage")

preamble <- c(
  "% Built by scripts/09_jse_to_tex.R from docs/draft/draft_v4_jse.md (Journal of Sports Economics / APA 7 layout).",
  "% Compile from docs/draft: pdflatex draft_v4_jse.tex (twice).",
  "\\documentclass[12pt]{article}",
  "\\usepackage[margin=1in]{geometry}",
  "\\usepackage{mathptmx}",
  "\\usepackage[T1]{fontenc}\\usepackage[utf8]{inputenc}",
  "\\usepackage{amsmath,amssymb}",
  "\\usepackage{booktabs,threeparttable,graphicx,float,array}",
  "\\usepackage{setspace}\\doublespacing",
  "\\usepackage{endnotes}\\renewcommand{\\notesname}{Footnotes}",
  "\\usepackage{caption}",
  "\\captionsetup[table]{labelsep=newline,labelfont=bf,textfont=it,justification=raggedright,singlelinecheck=false,font=doublespacing}",
  "\\captionsetup[figure]{labelsep=period,labelfont=it,justification=raggedright,singlelinecheck=false,font=doublespacing}",
  "\\usepackage{hanging}",
  "\\usepackage[hidelinks]{hyperref}\\usepackage{xurl}",
  "\\emergencystretch 3em",
  "\\setlength{\\parindent}{0.5in}",
  "\\newcommand{\\lone}[1]{\\par\\medskip\\noindent\\begin{center}\\textbf{#1}\\end{center}\\par\\nopagebreak}",
  "\\newcommand{\\ltwo}[1]{\\par\\medskip\\noindent\\textbf{#1}\\par\\nopagebreak}",
  "\\newcommand{\\lthree}[1]{\\par\\noindent\\hspace{\\parindent}\\textbf{#1.}\\ }",
  "\\pagestyle{plain}",
  "\\begin{document}", ""
)
titlepage <- c(
  "\\thispagestyle{plain}", "\\begin{center}", paste0("{\\large\\textbf{", inline(title), "}}\\\\[2em]"),
  paste0(inline(field("Author")), "\\\\"), paste0(inline(field("Affiliation")), "\\\\"), paste0(inline(field("Address")), "\\\\[2em]"), "\\end{center}",
  "\\noindent\\textbf{Corresponding author:} ", inline(field("Corresponding author")), "\\par",
  "\\noindent\\textbf{ORCID iD:} ", inline(field("ORCID")), "\\par",
  "\\noindent\\textbf{Acknowledgments:} ", inline(field("Acknowledgments")), "\\par",
  "\\noindent\\textbf{Funding:} ", inline(field("Funding")), "\\par",
  "\\noindent\\textbf{Declarations:} ", inline(field("Declaration")), "\\par",
  "\\clearpage"
)
abstractpage <- c("\\begin{center}\\textbf{", inline(title), "}\\end{center}", "\\lone{Abstract}", "\\noindent ", inline(abstract), "\\par\\bigskip",
                  "\\noindent\\emph{Keywords:} ", inline(keywords), "\\clearpage")
textpage <- c("\\begin{center}\\textbf{", inline(title), "}\\end{center}", "", body)
# Main manuscript: title page, abstract, text, notes, references, tables, figures.
# Appendix A is written as a separate supplementary file so the main manuscript stays near the journal's page norm.
tex <- c(preamble, titlepage, abstractpage, textpage, "", "\\clearpage", "\\begingroup\\parindent0pt", "\\theendnotes", "\\endgroup", "\\clearpage",
         "\\lone{References}", "\\begin{hangparas}{0.5in}{1}", refs, "\\end{hangparas}", "\\clearpage",
         "\\lone{Tables}", unlist(map(main_tables, tab_block)),
         "\\lone{Figures}", unlist(map(names(figure_captions)[1:5], fig_block)),
         "\\end{document}")
write_lines(tex, TEX)
cat("  wrote", TEX, "with", length(tex), "lines\n")
APP <- "docs/draft/draft_v4_jse_appendix.tex"
app <- c(preamble, "\\begin{center}\\textbf{", inline(title), "}\\\\[1em] Supplementary material\\end{center}",
         "\\setcounter{table}{0}\\renewcommand{\\thetable}{A\\arabic{table}}", "\\setcounter{figure}{0}\\renewcommand{\\thefigure}{A\\arabic{figure}}",
         "\\lone{Appendix A. Additional Tables and Figures}",
         "\\noindent Tables A1 to A19 and Figures A1 to A3 are referenced in the text of the main manuscript. Table and figure sources are listed in the Markdown source of the manuscript.\\clearpage",
         unlist(map(app_tables, tab_block)), unlist(map(names(figure_captions)[6:8], fig_block)), "\\end{document}")
write_lines(app, APP)
cat("  wrote", APP, "with", length(app), "lines\n")
check(sum(str_count(tex, fixed("\\endnote{"))) == length(footnotes), "every note spliced as an endnote")
cat("Done.\n")
