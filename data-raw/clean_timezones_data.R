library(rgdal)
library(dplyr)

setwd("data-raw")
timezones <- readOGR(dsn = "c_05ap16a", layer = "c_05ap16")

clean_tzs <- function(tz){
  tz <- toupper(tz)
  tz[grepl("E", tz)] <- "US/Eastern"
  tz[grepl("C", tz)] <- "US/Central"
  tz[grepl("M", tz)] <- "US/Mountain"
  tz[grepl("P", tz)] <- "US/Pacific"
  tz[grepl("H", tz)] <- "US/Hawaii"
  tz[grepl("A", tz)] <- "US/Alaska"
  return(tz)
}

county_tzs <- timezones@data %>%
  dplyr::rename(lat = LAT, lon = LON, state = STATE, fips = FIPS, tz = TIME_ZONE,
         county_name = COUNTYNAME) %>%
  select(-CWA, -FE_AREA) %>%
  filter(!(state %in% c("AS", "GU", "PR", "VI"))) %>%
  mutate(tz = clean_tzs(tz),
         fips = as.character(fips))
county_tzs$fips[county_tzs$fips == "46102"] <- "46113"
county_tzs <- rbind(county_tzs,
                    c(NA, NA, "HI", NA, "15005", "US/Hawaii"),
                    c(NA, NA, "VA", NA, "51515", "US/Eastern"))

library(choroplethr)
to_map <- county_tzs %>%
  select(fips, tz) %>%
  dplyr::rename(region = fips, value = tz) %>%
  mutate(region = as.numeric(as.character(region)))
county_choropleth(unique(to_map))
