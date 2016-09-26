#' Add local time to dataset
#'
#' This function inputs a dataframe of observations for US counties that
#' includes a column with date-time expressed in Coordinated Universal Time
#' (UTC), as well as a single value or vector of FIPS code(s) for the
#' county associated with each observation. It will return the
#' original dataframe with columns added for local date-time, local date, and,
#' if specified, local time zone.
#'
#' @param df A dataframe of observations that includes a column with a
#'    date-time object in Coordinated Universal Time (UTC) (see the documentation
#'    for the \code{\link{calc_local_time}} function to see requirements for
#'    the format of this UTC date-time column)
#' @param datetime_colname A character string giving the column name for the
#'    column that gives date-time in UTC in the input dataframe.
#' @inheritParams calc_local_time
#'
#' @return This function returns the dataframe input to the function, with
#'    columns added with local date-time, local date, and, if specified, local
#'    time zone.
#'
#' @examples
#' ex_df <- data.frame(datetime = c("1999-01-01 08:00", "1999-01-01 09:00",
#'                                  "1999-01-01 10:00"),
#'                     fips = c("36061", "17031", "06037"))
#' add_local_time(df = ex_df, fips = ex_df$fips,
#'                datetime_colname = "datetime")
#'
#' ex_df <- data.frame(datetime = c("1999-01-01 08:00", "1999-01-01 09:00",
#'                                  "1999-01-01 10:00"))
#' add_local_time(df = ex_df, fips = "36061", datetime_colname = "datetime")
#'
#' @export
add_local_time <- function(df, fips, datetime_colname, include_tz = TRUE){
  date_time <- df[ , datetime_colname]
  local_time <- calc_local_time(date_time = date_time, fips = fips,
                                include_tz = include_tz)
  out <- cbind(df, local_time)
  return(out)
}

#' Calculate local time from UTC for US counties
#'
#' This function inputs date-time values in Coordinated Universal Time (UTC;
#' also known as Zulu Time), along with a vector with county Federal Information
#' Processing Standard (FIPS) codes, and calculates the local date-time as
#' well as the local date based on th UTC date-time.
#'
#' This function inputs date-time values in Coordinated Universal Time (UTC;
#' also known as Zulu Time), as well as a single value or vector of FIPS code(s) for the
#' county associated with each observation. It returns a dataframe with
#' columns for local date-time, local date, and, if specified, local time zone.
#'
#' @param date_time The vector of the date-time of each observation in
#'    Coordinated Universal Time (UTC). This vector can either have a
#'    \code{POSIXct} class or be a character string, with date-time given
#'    as four-digit year, two-digit month, two-digit day, two-digit hour,
#'    and two-digit minutes (with hours based on a 24-hour system). Examples
#'    of acceptable formats include, for the example of 1:00 PM Jan. 2 1999,
#'    "199901021300", "1999-01-02 13:00", and "1999/01/02 13:00".
#' @param fips A character vector giving the 5-digit FIPS code of the county
#'    associated with each observation. This can be either a string of length 1,
#'    if all observations come from the same county, or a vector as long as the
#'    \code{date_time} vector, if different observations come from different
#'    counties.
#' @param include_tz A TRUE / FALSE value specifying whether to include a
#'    column with the local time zone (\code{local_tz}) in the final output.
#'
#' @return This function returns a dataframe with columns for local date-time,
#'    local date, and, if specified, local time zone.
#'
#' @note The local time is given as a character
#'    string, rather than a POSIXct object, so that it can have different time
#'    zones for different counties within the same dataframe (i.e., if there
#'    are two counties in the dataframe that are in different time zones).
#'
#' @examples
#' calc_local_time(date_time = "1999-01-01 08:00", fips = "36061")
#'
#' ex_datetime <- c("1999-01-01 08:00", "1999-01-01 09:00",
#'                  "1999-01-01 10:00")
#' calc_local_time(date_time = ex_datetime, fips = "36061")
#'
#' ex_datetime <- c("1999-01-01 08:00", "1999-01-01 09:00",
#'                  "1999-01-01 10:00")
#' ex_fips <- c("36061", "17031", "06037")
#' calc_local_time(date_time = ex_datetime, fips = ex_fips)
#'
#' @importFrom dplyr %>%
#'
#' @export
calc_local_time <- function(date_time, fips, include_tz = TRUE){
  fips <- as.numeric(as.character(fips))

  wrong_fips <- fips[!(fips %in% countytimezones::county_tzs$fips)]
 if(!nchar(fips) == 5 ){
    warning(paste("The following FIPS did not match the five-character format:",
                  paste(fips,collapse = ", ")))
    fips <- fips[(fips %in% countytimezones::county_tzs$fips)]
 } else {
   if (length(wrong_fips) > 0){
   warning(paste("The following FIPS did not match values in our dataset:",
                 paste(wrong_fips, collapse = ", ")))
   fips <- fips[(fips %in% countytimezones::county_tzs$fips)]
   }



   convert.to.date <- function(dt) {
     dt <- strptime(dt, '%Y-%m-%d %H:%M')
     if(is.na(dt)) stop("Format incorrect")
     return(dt)
   }

   convert.to.date(date_time)
 }




  # Convert date-time to POSIXct class if it's not already
  if(!("POSIXct" %in% class(date_time))){
    date_time <- lubridate::ymd_hm(date_time)
  }

  if(include_tz){
    dots <- c("local_time", "local_date", "local_tz")
  } else {
    dots <- c("local_time", "local_date")
  }

  df <- data.frame(date_time, fips) %>%
    dplyr::mutate_(fips = ~ as.numeric(as.character(fips))) %>%
    dplyr::left_join(countytimezones::county_tzs, by = "fips") %>%
    dplyr::rename_(local_tz = ~ tz) %>%
    dplyr::mutate_(local_time = ~ mapply(calc_single_datetime,
                                         date_time, tz = local_tz),
                   local_time = ~ lubridate::ymd_hms(local_time),
                   local_date = ~ format(local_time, "%Y-%m-%d"),
                   local_time = ~ format(local_time, "%Y-%m-%d %H:%M")) %>%
    dplyr::select_(.dots = dots)
  return(df)
}

#' Convert UTC to local time for a single observation
#'
#' This function calculated the local date-time for an observation based on a
#' date-time in Coordinated Universal Time (UTC). The function provides a
#' wrapper for the \code{with_tz} function form the \code{lubridate} package.
#' It converts output from the \code{with_tz} function to a character vector
#' so other functions in this package can be applied without error to
#' with a dataframe with observations from multiple time zones to local time.
#'
#' @param datetime A POSIXct object of length one expressed in Coordinated
#'    Universal Time (UTC)
#' @param tz A character string giving the local time zone based on the
#'    Olson/IANA time zone names
#'
#' @return A character string giving the date-time in the local time zone
#'
#' @examples
#' utc_time <- as.POSIXct("1999-09-15 14:30:00", tz = "UTC")
#' local_time <- calc_single_datetime(utc_time, tz = "US/Eastern")
#'
#' @export
calc_single_datetime <- function(datetime, tz){
  local_time <- lubridate::with_tz(datetime, tzone = tz)
  local_time <- format(local_time, format = "%Y%m%d%H%M%S")
  return(local_time)
}

