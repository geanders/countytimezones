library(rgdal)
library(dplyr)

setwd("data-raw")
timezones <- readOGR(dsn = "c_05ap16a", layer = "c_05ap16")
timezones <- timezones@data %>%
  rename(lat = LAT, lon = LON, state = STATE, fips = FIPS, tz = TIME_ZONE,
         county_name = COUNTYNAME) %>%
  select(-CWA, -FE_AREA)
