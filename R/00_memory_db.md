Tietokantahommat kätevästi R:llä
================
Pasi Haapakorva
Sat Feb 16 21:18:45 2019

Demoan lyhyesti tietokantayhtyettä R:llä. R:ssä tietokantataulujen
käsittely on parhaimmillaan hyvin kätevää, koska käytössä ovat
valmiiksi tutut `dplyr`-verbit.

Ladataan ensin paketit.

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
dbWriteTable(dbcon, "mtcars", mtcars %>% as_tibble(rownames = "name"))

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

`dplyr`:stä saa tarvittaessa ulos, esimerkiksi muille jaettavaksi,
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

Tietokantataulusta saadaan helposti myös paikallinen kopio.

``` r
(mtcars_local <- dbReadTable(dbcon, "mtcars") %>%
  as_tibble())
```

    ## # A tibble: 32 x 12
    ##    name     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
    ##    <chr>  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
    ##  1 Mazda~  21       6  160    110  3.9   2.62  16.5     0     1     4     4
    ##  2 Mazda~  21       6  160    110  3.9   2.88  17.0     0     1     4     4
    ##  3 Datsu~  22.8     4  108     93  3.85  2.32  18.6     1     1     4     1
    ##  4 Horne~  21.4     6  258    110  3.08  3.22  19.4     1     0     3     1
    ##  5 Horne~  18.7     8  360    175  3.15  3.44  17.0     0     0     3     2
    ##  6 Valia~  18.1     6  225    105  2.76  3.46  20.2     1     0     3     1
    ##  7 Duste~  14.3     8  360    245  3.21  3.57  15.8     0     0     3     4
    ##  8 Merc ~  24.4     4  147.    62  3.69  3.19  20       1     0     4     2
    ##  9 Merc ~  22.8     4  141.    95  3.92  3.15  22.9     1     0     4     2
    ## 10 Merc ~  19.2     6  168.   123  3.92  3.44  18.3     1     0     4     4
    ## # ... with 22 more rows

Tai sitten voidaan ottaa vain
    siivu.

``` r
dbGetQuery(dbcon, "SELECT * FROM mtcars WHERE cyl > 4 AND mpg > 20")
```

    ##             name  mpg cyl disp  hp drat    wt  qsec vs am gear carb
    ## 1      Mazda RX4 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
    ## 2  Mazda RX4 Wag 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
    ## 3 Hornet 4 Drive 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1

`dbplyr`-paketissa on tietokantoja varten metodit `dplyr`:n
liitosfunktioille.

``` r
library(dbplyr)
```

Lisätään kantaan tällä kertaa `dplyr::copy_to()`:lla kaksi taulua,
joista jää tilapäiset yhteydet.

``` r
members <- copy_to(dbcon, band_members, "members")
instruments <- copy_to(dbcon, band_instruments, "instruments")
```

Voidaan tehdä liitos.

``` r
members %>%
  left_join(instruments)
```

    ## # Source:   lazy query [?? x 3]
    ## # Database: sqlite 3.22.0 [:memory:]
    ##   name  band    plays 
    ##   <chr> <chr>   <chr> 
    ## 1 Mick  Stones  <NA>  
    ## 2 John  Beatles guitar
    ## 3 Paul  Beatles bass

Suljetaan yhteys.

``` r
dbDisconnect(dbcon)
```
