Tietokantahommat kÃ¤tevÃ¤sti R:llÃ¤
================
pasih
Sat Feb 16 20:01:33 2019

Demoan lyhyesti tietokantayhtyettÃ¤ R:llÃ¤. Ladataan ensin paketit.

R:ssÃ¤ tietokantataulujen kÃ¤sittely on parhaimmillaan hyvin kÃ¤tevÃ¤Ã¤,
koska kÃ¤ytÃ¶ssÃ¤ ovat valmiiksi tutut `dplyr`-verbit.

``` r
library(DBI)
library(dplyr)
```

Luodaan muistiin SQLite-tietokanta.

``` r
dbcon <- dbConnect(RSQLite::SQLite(), ":memory:")
```

LisÃ¤tÃ¤Ã¤n kantaan `mtcars`-taulu.

``` r
dbWriteTable(dbcon, "mtcars", mtcars)

dbListTables(dbcon)
```

    ## [1] "mtcars"

Luodaan tietokannan `mtcars`-taulusta referenssi.

``` r
mtcars_db <- tbl(dbcon, "mtcars")
```

TehdÃ¤Ã¤n kevyttÃ¤ laskentaa.

``` r
mtcars_db %>%
  group_by(cyl) %>%
  summarise(mean_mpg = mean(mpg, na.rm = TRUE))
```

    ## # Source:   lazy query [?? x 2]
    ## # Database: sqlite 3.22.0 [:memory:]
    ##     cyl mean_mpg
    ##   <dbl>    <dbl>
    ## 1     4     26.7
    ## 2     6     19.7
    ## 3     8     15.1

dplyristÃ¤ saa tarvittaessa ulos, esimerkiksi muille jaettavaksi,
SQL-queryn.

``` r
mtcars_db %>%
  group_by(cyl) %>%
  summarise(mean_mpg = mean(mpg, na.rm = TRUE)) %>%
  show_query()
```

    ## <SQL>
    ## SELECT `cyl`, AVG(`mpg`) AS `mean_mpg`
    ## FROM `mtcars`
    ## GROUP BY `cyl`
