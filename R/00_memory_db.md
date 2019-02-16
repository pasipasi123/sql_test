Tietokantahommat kätevästi R:llä
================
pasih
Sat Feb 16 20:01:14 2019

Demoan lyhyesti tietokantayhtyettä R:llä. Ladataan ensin paketit.

R:ssä tietokantataulujen käsittely on parhaimmillaan hyvin kätevää,
koska käytössä ovat valmiiksi tutut `dplyr`-verbit.

``` r
library(DBI)
library(dplyr)
```

Luodaan muistiin SQLite-tietokanta.

``` r
dbcon <- dbConnect(RSQLite::SQLite(), ":memory:")
```

Lisätään kantaan `mtcars`-taulu.

``` r
dbWriteTable(dbcon, "mtcars", mtcars)

dbListTables(dbcon)
```

    ## [1] "mtcars"

Luodaan tietokannan `mtcars`-taulusta referenssi.

``` r
mtcars_db <- tbl(dbcon, "mtcars")
```

Tehdään kevyttä laskentaa.

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

dplyristä saa tarvittaessa ulos, esimerkiksi muille jaettavaksi,
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
