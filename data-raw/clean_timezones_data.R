## Starting with US Census data
## Using info from http://www.statoids.com/tus.html on which counties are in which
## time zone
## Updated to be based on http://efele.net/maps/tz/us/
find_state_tz <- function(state){
  if(state %in% c("AL", "AR", "IL", "IA", "KS", "LA", "MN", "MS", "MO",
                  "NE", "ND", "OK", "SD", "TN", "TX", "WI")){
    tz <- "America/Chicago"
  } else if(state %in% c("CT", "DE", "DC", "FL", "GA", "KY", "ME",
                         "MD", "MA", "MI", "NH", "NJ", "NY", "NC", "OH",
                         "PA", "RI", "SC", "VT", "VA", "WV")){
    tz <- "America/New_York"
  } else if(state %in% c("CO", "MT", "NM", "UT", "WY")){
    tz <- "America/Denver"
  } else if(state %in% c("CA", "NV", "OR", "WA")){
    tz <- "America/Los_Angeles"
  } else if(state %in% c("AK")){
    tz <- "America/Anchorage"
  } else if(state %in% c("AZ")){
    tz <- "America/Phoenix"
  } else if(state %in% c("HI")){
    tz <- "Pacific/Honolulu"
  } else if(state %in% "ID"){
    tz <- "America/Boise"
  } else if(state %in% "IN"){
    tz <- "America/Indiana/Indianapolis"
  }
  return(tz)
}

library(dplyr)
library(tidyr)
county_df <- read.csv("http://www2.census.gov/geo/docs/reference/codes/files/national_county.txt",
                      header = FALSE, as.is = TRUE,
                      col.names = c("state", "st_fips", "ct_fips", "county", "code")) %>%
  mutate(ct_fips = sprintf("%03d", ct_fips)) %>%
  unite(fips, st_fips, ct_fips, sep = "") %>%
  mutate(fips = as.numeric(fips)) %>%
  filter(!(state %in% c("AS", "GU", "MP", "PR", "UM", "VI")) ) %>%
  mutate(tz = sapply(state, find_state_tz),
         county = tolower(county))

county_df[county_df$state == "AK" &
            county_df$county %in% c("aleutians west census area"),
          "tz"] <- "America/Adak"
county_df[county_df$state == "AK" &
            county_df$county %in% c("yakutat city and borough"),
          "tz"] <- "America/Yakutat"
county_df[county_df$state == "AK" &
            county_df$county %in% c("skagway municipality",
                                    "hoonah-angoon census area",
                                    "juneau city and borough",
                                    "haines borough"),
          "tz"] <- "America/Juneau"
county_df[county_df$state == "AK" &
            county_df$county %in% c("wrangell city and borough",
                                    "petersburg census area",
                                    "sitka city and borough",
                                    "ketchikan gateway borough",
                                    "prince of wales-hyder census area"),
          "tz"] <- "America/Sitka"
# Need "Alaska/Nome" for west of 162 degrees
county_df[county_df$state == "AZ" &
            county_df$county %in% paste(c("apache","coconino","navajo"),
                                        "county"), "tz"] <- "America/Chicago"
county_df[county_df$state == "FL" &
            county_df$county %in% paste(c("bay", "calhoun", "escambia", "gulf",
                                          "holmes", "jackson", "okaloosa",
                                          "santa rosa", "walton", "washington"),
                                        "county"), "tz"] <- "America/Chicago"
county_df[county_df$state == "ID" &
            county_df$county %in% paste(c("benewah", "bonner", "boundary",
                                          "clearwater", "kootenai", "latah",
                                          "lewis", "nez perce", "shoshone",
                                          "idaho"),
                                        "county"), "tz"] <- "America/Los_Angeles"
county_df[county_df$state == "IN" &
            county_df$county %in% paste(c("crawford"), "county"),
          "tz"] <- "America/Indiana/Marengo"
county_df[county_df$state == "IN" &
            county_df$county %in% paste(c("daviess", "dubois", "knox",
                                          "martin"), "county"),
          "tz"] <- "America/Indiana/Vincennes"
county_df[county_df$state == "IN" &
            county_df$county %in% paste(c("perry"), "county"),
          "tz"] <- "America/Indiana/Tell_City"
county_df[county_df$state == "IN" &
            county_df$county %in% paste(c("pike"), "county"),
          "tz"] <- "America/Indiana/Petersburg"
county_df[county_df$state == "IN" &
            county_df$county %in% paste(c("starke"), "county"),
          "tz"] <- "America/Indiana/Knox"
county_df[county_df$state == "IN" &
            county_df$county %in% paste(c("pulaski"), "county"),
          "tz"] <- "America/Indiana/Winamac"
county_df[county_df$state == "IN" &
            county_df$county %in% paste(c("switzerland"), "county"),
          "tz"] <- "America/Indiana/Vevay"
county_df[county_df$state == "IN" &
            county_df$county %in% paste(c("clark", "floyd", "harrison"), "county"),
          "tz"] <- "America/Kentucky/Louisville"
county_df[county_df$state == "IN" &
            county_df$county %in% paste(c("dearborn", "ohio"), "county"),
          "tz"] <- "America/New_York"
county_df[county_df$state == "IN" &
            county_df$county %in% paste(c("gibson", "jasper", "lake",
                                          "laporte", "newton", "perry",
                                          "porter", "posey", "spencer",
                                          "starke", "vanderburgh",
                                          "warrick"), "county"), "tz"] <- "America/Chicago"
county_df[county_df$state == "KS" &
            county_df$county %in% paste(c("greeley", "hamilton",
                                          "sherman", "wallace"),
                                        "county"), "tz"] <- "America/Denver"
county_df[county_df$state == "KY" &
            county_df$county %in% paste(c("adair", "allen", "ballard", "barren",
                                          "breckinridge", "butler", "caldwell",
                                          "calloway", "carlisle", "christian",
                                          "clinton", "crittenden", "cumberland",
                                          "daviess", "edmonson", "fulton", "graves",
                                          "grayson", "green", "hancock", "hart",
                                          "henderson", "hickman", "hopkins",
                                          "livingston", "logan", "lyon", "marshall",
                                          "mccracken", "mclean", "metcalfe", "monroe",
                                          "muhlenberg", "ohio", "russell", "simpson",
                                          "todd", "trigg", "union", "warren", "webster"),
                                        "county"), "tz"] <- "America/Chicago"
county_df[county_df$state == "KY" &
            county_df$county %in% paste(c("jefferson"),
                                        "county"), "tz"] <- "America/Kentucky/Louisville"
county_df[county_df$state == "KY" &
            county_df$county %in% paste(c("wayne"),
                                        "county"), "tz"] <- "America/Kentucky/Monticello"
county_df[county_df$state == "MI" &
            county_df$county %in% paste(c("dickinson", "gogebic", "iron",
                                          "menominee"),
                                        "county"), "tz"] <- "America/Menominee"
county_df[county_df$state == "NE" &
            county_df$county %in% paste(c("arthur", "banner", "box butte",
                                          "chase", "cherry", "cheyenne", "dawes", "deuel",
                                          "dundy", "garden", "grant", "hooker",
                                          "keith", "kimball", "morrill",
                                          "perkins", "scotts bluff", "sheridan",
                                          "sioux"),
                                        "county"), "tz"] <- "America/Denver"
county_df[county_df$state == "ND" &
            county_df$county %in% paste(c("adams", "billings", "bowman", "dunn",
                                          "golden valley", "grant", "hettinger",
                                          "slope", "stark"),
                                        "county"), "tz"] <- "America/Denver"
county_df[county_df$state == "ND" &
            county_df$county %in% paste(c("oliver"),
                                        "county"), "tz"] <- "America/North_Dakota/Center"
county_df[county_df$state == "ND" &
            county_df$county %in% paste(c("morton"),
                                        "county"), "tz"] <- "America/North_Dakota/New_Salem"
county_df[county_df$state == "ND" &
            county_df$county %in% paste(c("mercer"),
                                        "county"), "tz"] <- "America/North_Dakota/Beulah"
county_df[county_df$state == "OR" &
            county_df$county %in% paste(c("malheur"),
                                        "county"), "tz"] <- "America/Denver"
county_df[county_df$state == "SD" &
            county_df$county %in% paste(c("bennett", "butte", "corson", "custer",
                                          "dewey", "fall river", "haakon", "harding",
                                          "jackson", "lawrence", "meade", "pennington",
                                          "perkins", "shannon", "stanley", "ziebach"),
                                        "county"), "tz"] <- "America/Denver"
county_df[county_df$state == "TN" &
            county_df$county %in% paste(c("anderson", "blount", "bradley",
                                          "campbell", "carter", "claiborne",
                                          "cocke", "grainger", "greene",
                                          "hamblen", "hamilton", "hancock",
                                          "hawkins", "jefferson", "johnson",
                                          "knox", "loudon", "mcminn", "meigs",
                                          "monroe", "morgan", "polk", "rhea",
                                          "roane", "scott", "sevier", "sullivan",
                                          "unicoi", "union", "washington"),
                                        "county"), "tz"] <- "America/New_York"
county_df[county_df$state == "TX" &
            county_df$county %in% paste(c("el paso", "hudspeth"),
                                        "county"), "tz"] <- "America/Denver"
county_tzs <- select(county_df, fips, tz, county, state)
library(devtools)
use_data(county_tzs, overwrite = TRUE)
