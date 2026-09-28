# =============================================================================
# 07_bbr_boxscore_check.R
#
# Verify the mechanism behind ESPN "no row" absences against Basketball-Reference
# box scores, which list "Did Not Play"/"Did Not Dress"/"Not With Team" players
# inside the box and "Inactive" players below it. One game per selected season,
# chosen so that a star has a no-row absence and the team also has an ESPN DNP row.
# Pages are requested once, politely (20 s apart), and cached in data/raw/bbr/boxscores.
# Requested explicitly by the PI on 2026-09-16; this is the only BBR request since setup.
# =============================================================================
suppressPackageStartupMessages({ library(tidyverse); library(rvest); library(stringi) })
PROJECT_ROOT <- "/Users/maddockl/nba-65-game-rule"; setwd(PROJECT_ROOT)
dir.create("data/raw/bbr/boxscores", showWarnings = FALSE, recursive = TRUE)
check <- function(cond, msg) { if (!isTRUE(cond)) stop("CHECK FAILED: ", msg, call. = FALSE); cat("  ok:", msg, "\n") }
norm <- function(x) x %>% stri_trans_general("Latin-ASCII") %>% str_to_lower() %>% str_remove_all("[.'’,]") %>% str_remove_all("\\b(jr|sr|ii|iii|iv)\\b") %>% str_squish()
set.seed(7)

panel    <- read_rds("data/derived/player_game_panel.rds")
pb       <- read_rds("data/intermediate/player_box.rds")
schedule <- read_rds("data/intermediate/schedule.rds")
abbr_lu  <- pb %>% group_by(team_id) %>% summarise(team_abbr = last(team_abbr), .groups = "drop")
bbr_code <- c(ATL="ATL", BOS="BOS", BKN="BRK", CHA="CHO", CHI="CHI", CLE="CLE", DAL="DAL", DEN="DEN", DET="DET", GS="GSW", HOU="HOU",
              IND="IND", LAC="LAC", LAL="LAL", MEM="MEM", MIA="MIA", MIL="MIL", MIN="MIN", NO="NOP", NY="NYK", OKC="OKC", ORL="ORL",
              PHI="PHI", PHX="PHO", POR="POR", SAC="SAC", SA="SAS", TOR="TOR", UTAH="UTA", WSH="WAS")

# One game per season: a star with a no-row absence, on a team-game that also has an ESPN DNP row
cands <- panel %>% filter(star_ppp, absence_type == "no_row", !covid, season %in% c(2015, 2017, 2019, 2023, 2024, 2025, 2026)) %>%
  select(season, game_id, team_id, athlete_name, game_date) %>%
  semi_join(pb %>% filter(did_not_play) %>% distinct(game_id, team_id), by = c("game_id", "team_id")) %>%
  group_by(season) %>% slice_sample(n = 1) %>% ungroup() %>%
  inner_join(schedule %>% select(game_id, home_id), by = "game_id") %>%
  inner_join(abbr_lu %>% rename(home_abbr = team_abbr), by = c("home_id" = "team_id")) %>%
  mutate(bbr_home = bbr_code[home_abbr], url = sprintf("https://www.basketball-reference.com/boxscores/%s0%s.html", format(game_date, "%Y%m%d"), bbr_home),
         cache = file.path("data/raw/bbr/boxscores", sprintf("%s0%s.html", format(game_date, "%Y%m%d"), bbr_home)))
print(cands %>% select(season, game_date, athlete_name, home_abbr, bbr_home))

results <- map_dfr(seq_len(nrow(cands)), function(i) {
  g <- cands[i, ]
  if (!file.exists(g$cache)) { Sys.sleep(20); cat("  fetching", g$url, "\n"); page <- tryCatch(read_html(g$url), error = function(e) NULL)
    if (is.null(page)) return(tibble(season = g$season, status = "fetch failed")); writeLines(as.character(page), g$cache) }
  page <- read_html(g$cache)
  txt  <- page %>% html_text2()
  # Inactive lists appear as "Inactive: TEAM Player, Player; TEAM Player, ..." near the bottom of the page
  inactive_txt <- str_extract(txt, "Inactive:[^\\n]*")
  # the line reads "Inactive: NOP Player, Player DEN Player, Player"; team codes separate the two lists
  inactive_names <- if (is.na(inactive_txt)) character(0) else inactive_txt %>% str_remove("Inactive:") %>%
    str_replace_all("\\b[A-Z]{3}\\b", ",") %>% str_split("[,;]") %>% unlist() %>% str_squish() %>% keep(~ nchar(.x) > 2)
  # Box tables: players with "Did Not Play", "Did Not Dress", "Not With Team", "Player Suspended" in the reason cell
  tabs <- page %>% html_elements("table[id$='-game-basic']")
  dnp_bbr <- map_dfr(tabs, function(t) {
    rows <- t %>% html_elements("tbody tr")
    map_dfr(rows, function(r) { nm <- r %>% html_element("th") %>% html_text2(); rs <- r %>% html_element("td[data-stat='reason']") %>% html_text2()
      tibble(player = nm, reason = rs) }) %>% filter(!is.na(reason), reason != "")
  })
  in_table <- map_dfr(tabs, function(t) tibble(player = t %>% html_elements("tbody tr th") %>% html_text2())) %>% filter(player != "", player != "Reserves")
  # ESPN side, both teams
  espn <- pb %>% filter(game_id == g$game_id) %>% transmute(player = athlete_name, dnp = did_not_play, key = norm(athlete_name))
  bbr_tab_keys <- norm(in_table$player); bbr_dnp_keys <- norm(dnp_bbr$player); inact_keys <- norm(inactive_names)
  tibble(season = g$season, game_date = g$game_date, url = g$url, status = "ok",
         espn_rows = nrow(espn), espn_dnp_rows = sum(espn$dnp), bbr_table_rows = length(bbr_tab_keys), bbr_dnp_rows = nrow(dnp_bbr), bbr_inactive = length(inact_keys),
         espn_rows_in_bbr_table = sum(espn$key %in% bbr_tab_keys), espn_dnp_in_bbr_dnp = sum(espn$key[espn$dnp] %in% bbr_dnp_keys),
         espn_dnp_in_bbr_inactive = sum(espn$key[espn$dnp] %in% inact_keys),
         bbr_inactive_with_espn_row = sum(inact_keys %in% espn$key),
         star_checked = g$athlete_name, star_in_bbr_inactive = norm(g$athlete_name) %in% inact_keys, star_in_bbr_table = norm(g$athlete_name) %in% bbr_tab_keys,
         bbr_dnp_reasons = paste(unique(dnp_bbr$reason), collapse = " | "))
})
print(results %>% select(-url, -bbr_dnp_reasons), width = Inf)
cat("\nBBR reasons on in-table non-players:\n"); print(results %>% select(season, bbr_dnp_reasons), width = Inf)
write_csv(results, "results/tables/bbr_boxscore_check.csv")
ok <- results %>% filter(status == "ok")
check(nrow(ok) >= 5, "at least five box scores checked")
check(all(ok$espn_dnp_in_bbr_dnp == ok$espn_dnp_rows), "every ESPN DNP row appears as a Did-Not-Play/Dress row inside the BBR box")
check(all(ok$bbr_inactive_with_espn_row == 0), "no BBR-inactive player has an ESPN row")
check(all(ok$star_in_bbr_inactive), "each checked star with a no-row absence is on the BBR inactive list")
cat("\nDone.\n")
