#' Add local time from UTC for US counties
#'
#' @param df A dataframe with columns with county FIPS numbers (\code{fips})
#'    and datetime in UTC.
#' @param date_colname A character string giving the name of the column in
#'    the dataframe with a datetime in the UTC timezone.
#'
#' @return This function returns the dataframe that was input, but with added
#'    columns for \code{local_time} (a character string giving the local date
#'    in the format "\%Y\%m\%d\%H\%m\%s") and \code{local_date} (a Date object
#'    giving the date in the local time).
#'
#' @note The local time is given as a character
#'    string, rather than a POSIXct object, so that it can have different time
#'    zones for different counties within the same dataframe (i.e., if there
#'    are two counties in the dataframe that are in different time zones).
#'
#' @examples
#' library(hurricaneexposure)
#' data(closest_dist)
#' library(lubridate)
#' floyd <- filter(closest_dist, storm_id == "Floyd-1999") %>%
#'          mutate(closest_date = ymd_hm(closest_date, tz = "UTC"))
#' floyd <- add_local_time(df = floyd, date_colname = "closest_date")
#'
#' @importFrom dplyr %>%
#'
#' @export
add_local_time <- function(df, date_colname){
  df$datetime <- df[ , date_colname]
  df <- dplyr::mutate_(df, fips = ~ as.numeric(fips))
  df <- dplyr::left_join(df, county_tzs, by = "fips") %>%
    dplyr::mutate_(local_time = ~ mapply(calc_single_datetime,
                                         datetime, tz = tz),
           local_date = ~ substring(local_time, 1, 8))
  return(df)
}

#' Calculate local time for a single observation
#'
#' @param datetime A POSIXct object in UTC timezone
#' @param tz A character string giving the local timezone
#'
#' @return A character string giving the time in the local timezone
#'
#' @note This must output the date as a character string, because otherwise
#'    all dates will be transformed to numeric values when you run the
#'    function through and \code{apply} function.
#'
#' @examples
#' utc_time <- as.POSIXct("1999-09-15 14:30:00", tz = "GMT")
#' local_time <- calc_single_datetime(utc_time, tz = "US/Eastern")
#'
#' @export
calc_single_datetime <- function(datetime, tz){
  local_time <- lubridate::with_tz(datetime, tzone = tz)
  local_time <- format(local_time, format = "%Y%m%d%H%M%S")
  return(local_time)
}

