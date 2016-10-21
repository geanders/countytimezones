
[![Travis-CI Build Status](https://travis-ci.org/geanders/countytimezones.svg?branch=master)](https://travis-ci.org/geanders/countytimezones)

<!-- README.md is generated from README.Rmd. Please edit that file -->
Aims of the package
-------------------

This package allows you to convert time from Coordinated Universal Time (UTC, also known as Zulu Time) to local time for US counties, based on each county's FIPs code. You can use this to convert time zones in dataframes where all observations are from one county, or also in a dataframe where observations come from from many different counties.

Many observational datasets express date-times using UTC, to ensure consistency across time zones. Examples include datasets for satellite-based or hourly weather data and aviation data (Morris 2008). It is often helpful to be able to convert date-time values for observations from UTC to local time, especially when combining with data measured or aggregated using local time (e.g., daily counts of health outcomes). This package allows you to make that conversion in a dataset, as long as each observation is associated with a US county Federal Information Processing Standard (FIPS) code. County time zone designations are based on Olson/IANA time zone conventions (see `?OlsonNames` for more information on these conventions).

These local time conversions take into account whether or not the county was observing Daylight Savings Time at the time of the observation. This package can be used both with datasets where all observations are from the same county and for datasets where observations are associated with a number of different counties.

Some counties include multiple time zones. For these counties, the package calculates local time based on the time zone used in the majority of the county, based on land area. Because some counties have more than one time zone, if you are aggregating data from monitors across a county, you should keep observations in UTC until all aggregating is complete and then convert the final, aggregated value to local time, rather than converting to local time before aggregation.

Accessing the package
---------------------

A stable version of this package is available on CRAN and can be installed directly from there:

``` r
install.packages("countytimezones")
```

The lastest development version of the package can also be loaded directly from GitHub using the `devtools` package:

``` r
library(devtools)
install_github("geanders/countytimezones")
library(countytimezones)
```

Simple example
--------------

As a very simple example, here is how you can calculate local time for a single observation in a single county:

``` r
calc_local_time(date_time = "1999-01-01 08:00", fips = "36061")
#>         local_time local_date         local_tz
#> 1 1999-01-01 03:00 1999-01-01 America/New_York
```

The column of local times is given in a character class because, while this package allows you to convert a dataset with observations from many different counties to the local time of each, a date-time vector in R can only have a single time zone associated with all values.

To calculate the same time in several different counties, you can run:

``` r
ex_fips <- c("36061", "17031", "06037")
calc_local_time(date_time = "1999-01-01 08:00", fips = ex_fips)
#>         local_time local_date            local_tz
#> 1 1999-01-01 03:00 1999-01-01    America/New_York
#> 2 1999-01-01 02:00 1999-01-01     America/Chicago
#> 3 1999-01-01 00:00 1999-01-01 America/Los_Angeles
```

You can also do conversions for more complex datasets, with different date-times and counties for each observation:

``` r
ex_datetime <- c("1999-01-01 08:00", "1999-01-01 09:00",
                 "1999-01-01 10:00")
ex_fips <- c("36061", "17031", "06037")
calc_local_time(date_time = ex_datetime, fips = ex_fips)
#>         local_time local_date            local_tz
#> 1 1999-01-01 03:00 1999-01-01    America/New_York
#> 2 1999-01-01 03:00 1999-01-01     America/Chicago
#> 3 1999-01-01 02:00 1999-01-01 America/Los_Angeles
```

From these examples, you can see that the `calc_local_time` function calculates a new dataframe with columns for `local_time`, `local_date`, and `local_tz` (this last column can be omitted by using the option `include_tz = FALSE`). If you want to add these columns to a dataframe, rather than generating them as a separate dataframe, you can instead use the function `add_local_time`. For example:

``` r
ex_df <- data.frame(datetime = c("1999-01-01 08:00", "1999-01-01 09:00",
                                 "1999-01-01 10:00"),
                    fips = c("36061", "17031", "06037"))
add_local_time(df = ex_df, fips = ex_df$fips,
              datetime_colname = "datetime")
#>           datetime  fips       local_time local_date            local_tz
#> 1 1999-01-01 08:00 36061 1999-01-01 03:00 1999-01-01    America/New_York
#> 2 1999-01-01 09:00 17031 1999-01-01 03:00 1999-01-01     America/Chicago
#> 3 1999-01-01 10:00 06037 1999-01-01 02:00 1999-01-01 America/Los_Angeles
```

More complex examples
---------------------

If you want to convert 8:30 UTC on Jan. 1, 1999 to local time in counties throughout the US, you could use the collection of FIPS codes from the `county_tz` dataset included with the package and run:

``` r
data(county_tzs)
example_df <- data.frame(fips = county_tzs$fips,
                 datetime = "1999-01-01 08:30")
head(example_df)
#>   fips         datetime
#> 1 1001 1999-01-01 08:30
#> 2 1003 1999-01-01 08:30
#> 3 1005 1999-01-01 08:30
#> 4 1007 1999-01-01 08:30
#> 5 1009 1999-01-01 08:30
#> 6 1011 1999-01-01 08:30

example_df <- add_local_time(df = example_df,
                             fips = example_df$fips,
                             datetime_colname = "datetime")
head(example_df)
#>   fips         datetime       local_time local_date        local_tz
#> 1 1001 1999-01-01 08:30 1999-01-01 02:30 1999-01-01 America/Chicago
#> 2 1003 1999-01-01 08:30 1999-01-01 02:30 1999-01-01 America/Chicago
#> 3 1005 1999-01-01 08:30 1999-01-01 02:30 1999-01-01 America/Chicago
#> 4 1007 1999-01-01 08:30 1999-01-01 02:30 1999-01-01 America/Chicago
#> 5 1009 1999-01-01 08:30 1999-01-01 02:30 1999-01-01 America/Chicago
#> 6 1011 1999-01-01 08:30 1999-01-01 02:30 1999-01-01 America/Chicago
```

You can use functions from the `choroplethr` package to map the local values:

``` r
library(choroplethr)
library(choroplethrMaps)
library(ggplot2)
library(dplyr)

to_plot <- example_df %>%
  select(fips, local_time) %>%
  mutate(local_time = factor(local_time)) %>%
  dplyr::rename(region = fips, value = local_time)
a <- CountyChoropleth$new(to_plot)
a$ggplot_scale <- scale_fill_brewer(type = "qual", drop = FALSE)
a$render()
```

![](README-unnamed-chunk-10-1.png)

Here is the same map for a date-time during the summer, when many counties use Daylight Savings Time:

``` r
example_df2 <- data.frame(fips = county_tzs$fips,
                 datetime = "1999-07-01 08:30") 
example_df2 <- add_local_time(example_df2, fips = example_df2$fips,
                              datetime_colname = "datetime")

to_plot <- example_df2 %>%
  select(fips, local_time) %>%
  mutate(local_time = factor(local_time)) %>%
  dplyr::rename(region = fips, value = local_time)
a <- CountyChoropleth$new(to_plot)
a$ggplot_scale <- scale_fill_brewer(type = "qual", drop = FALSE)
a$render()
```

![](README-unnamed-chunk-11-1.png)

From comparing these two maps, you can see some of counties that don't follow Daylight Savings Time (e.g., Arizona and parts of Indiana, although Indiana's Daylight Savings Time policies have changed more recently).

As another more complex example, the `floyd` example data that comes with this package has data on the date and time when Hurricane Floyd was closest to eastern US counties:

``` r
data(floyd)
head(floyd)
#>    fips closest_time_utc
#> 1 01001 1999-09-15 21:15
#> 2 01003 1999-09-15 17:30
#> 3 01005 1999-09-15 20:00
#> 4 01007 1999-09-15 22:00
#> 5 01009 1999-09-16 00:15
#> 6 01011 1999-09-15 20:30
```

``` r
eastern_states <- c("alabama", "arkansas", "connecticut", "delaware",
                            "district of columbia", "florida", "georgia", "illinois",
                            "indiana", "iowa", "kansas", "kentucky", "louisiana",
                            "maine", "maryland", "massachusetts", "michigan",
                            "mississippi", "missouri", "new hampshire", "new jersey",
                            "new york", "north carolina", "ohio", "oklahoma",
                            "pennsylvania", "rhode island", "south carolina",
                            "tennessee", "texas", "vermont", "virginia",
                            "west virginia", "wisconsin")

library(lubridate)
to_plot <- select(floyd, fips, closest_time_utc) %>%
  mutate(fips = as.numeric(fips),
         closest_time_utc = ymd_hm(closest_time_utc)) %>%
  mutate(closest_time_utc = format(closest_time_utc, "%Y-%m-%d")) %>%
  dplyr::rename(region = fips, value = closest_time_utc)
a <- CountyChoropleth$new(to_plot)
a$ggplot_scale <- scale_fill_brewer(type = "qual", drop = FALSE)
a$set_zoom(eastern_states)
a$render()
```

![](README-unnamed-chunk-13-1.png)

You can use the `add_local_time` function to convert all the UTC date-times from this dataset to each county's local time:

``` r
floyd <- add_local_time(floyd, fips = floyd$fips,
                        datetime_colname = "closest_time_utc")
head(floyd)
#>    fips closest_time_utc       local_time local_date        local_tz
#> 1 01001 1999-09-15 21:15 1999-09-15 16:15 1999-09-15 America/Chicago
#> 2 01003 1999-09-15 17:30 1999-09-15 12:30 1999-09-15 America/Chicago
#> 3 01005 1999-09-15 20:00 1999-09-15 15:00 1999-09-15 America/Chicago
#> 4 01007 1999-09-15 22:00 1999-09-15 17:00 1999-09-15 America/Chicago
#> 5 01009 1999-09-16 00:15 1999-09-15 19:15 1999-09-15 America/Chicago
#> 6 01011 1999-09-15 20:30 1999-09-15 15:30 1999-09-15 America/Chicago
```

``` r
to_plot <- select(floyd, fips, local_date) %>%
  mutate(fips = as.numeric(fips))%>%
  dplyr::rename(region = fips, value = local_date)
a <- CountyChoropleth$new(to_plot)
a$ggplot_scale <- scale_fill_brewer(type = "qual", drop = FALSE)
a$set_zoom(eastern_states)
a$render()
```

![](README-unnamed-chunk-15-1.png)

References
----------

Morris, Doug. 2008. “Time for the Weather-- Translating Zulu.” *Weatherwise* 61 (3): 32–35. doi:[10.3200/WEWI.61.3.32-35](https://doi.org/10.3200/WEWI.61.3.32-35).
