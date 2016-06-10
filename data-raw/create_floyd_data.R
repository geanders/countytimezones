library(hurricaneexposure)
library(dplyr)
library(devtools)
data(closest_dist)

floyd <- dplyr::filter(closest_dist, storm_id == "Floyd-1999") %>%
  select(fips, closest_time_utc)
use_data(floyd, overwrite = TRUE)
