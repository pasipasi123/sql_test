#' ---
#' title: Tietokantahommat kätevästi R:llä
#' output: github_document
#' author: Pasi Haapakorva
#' ---

#' Demoan lyhyesti tietokantayhtyettä R:llä. R:ssä tietokantataulujen käsittely on parhaimmillaan hyvin kätevää,
#' koska käytössä ovat valmiiksi tutut `dplyr`-verbit.
#'
#' Ladataan ensin paketit.

#+ koodia, message=FALSE, warning=FALSE
library(DBI)
library(dplyr)

#' Luodaan muistiin SQLite-tietokanta.

dbcon <- dbConnect(RSQLite::SQLite(), ":memory:")

#' Lisätään kantaan `mtcars`-taulu.

dbWriteTable(dbcon, "mtcars", mtcars %>% as_tibble(rownames = "name"))

dbListTables(dbcon)

#' Luodaan tietokannan `mtcars`-taulusta referenssi.

mtcars_db <- tbl(dbcon, "mtcars")

#' Tehdään kevyttä laskentaa.

mtcars_db %>%
  group_by(cyl) %>%
  summarise(mean_mpg = mean(mpg, na.rm = TRUE))

#' `dplyr`:stä saa tarvittaessa ulos, esimerkiksi muille jaettavaksi, SQL-queryn.

mtcars_db %>%
  group_by(cyl) %>%
  summarise(mean_mpg = mean(mpg, na.rm = TRUE)) %>%
  show_query()

#' Tietokantataulusta saadaan helposti myös paikallinen kopio.

(mtcars_local <- dbReadTable(dbcon, "mtcars") %>%
  as_tibble())

#' Tai sitten voidaan ottaa vain siivu.

dbGetQuery(dbcon, "SELECT * FROM mtcars WHERE cyl > 4 AND mpg > 20")

#' `dbplyr`-paketissa on tietokantoja varten metodit `dplyr`:n liitosfunktioille.

#+ koodia 2, message=FALSE, warning=FALSE
library(dbplyr)

#' Tehdään simppeli data.
join_data <- tribble(
  ~cyl, ~teksti,
  4,    "neljä",
  6,    "kuusi",
  8,    "kahdeksan"
)

#' Liitetään `join_data` referenssitauluun ja tallennetaan se kantaan.
#+ koodia 3, message=FALSE, warning=FALSE
mtcars_db %>%
  left_join(join_data, copy = TRUE) %>%
  copy_to(dest = dbcon, name = "mtcars_join")

dbReadTable(dbcon, "mtcars_join") %>%
  as_tibble() %>%
  select(name, cyl, teksti)

#' Suljetaan yhteys.
dbDisconnect(dbcon)
