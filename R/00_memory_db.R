#' ---
#' title: Tietokantahommat kätevästi R:llä
#' output: github_document
#' ---

#' Demoan lyhyesti tietokantayhtyettä R:llä. Ladataan ensin paketit.
#'
#' R:ssä tietokantataulujen käsittely on parhaimmillaan hyvin kätevää,
#' koska käytössä ovat valmiiksi tutut `dplyr`-verbit.

#+ koodia, message=FALSE, warning=FALSE
library(DBI)
library(dplyr)

#' Luodaan muistiin SQLite-tietokanta.

dbcon <- dbConnect(RSQLite::SQLite(), ":memory:")

#' Lisätään kantaan `mtcars`-taulu.

dbWriteTable(dbcon, "mtcars", mtcars)

dbListTables(dbcon)

#' Luodaan tietokannan `mtcars`-taulusta referenssi.

mtcars_db <- tbl(dbcon, "mtcars")

#' Tehdään kevyttä laskentaa.

mtcars_db %>%
  group_by(cyl) %>%
  summarise(mean_mpg = mean(mpg, na.rm = TRUE))

#' dplyristä saa tarvittaessa ulos, esimerkiksi muille jaettavaksi, SQL-queryn.

mtcars_db %>%
  group_by(cyl) %>%
  summarise(mean_mpg = mean(mpg, na.rm = TRUE)) %>%
  show_query()

