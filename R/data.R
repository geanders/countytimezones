#' County time zone designations
#'
#' A dataframe containing the Olson/IANA time zone designation of each US county,
#' based on the county's Federal Information Processing Standard
#' (FIPS) code. This dataset was put together based on county FIPS codes as of
#' the 2010 US Census, using text from the two websites listed in "Sources" to
#' set the time zone designation for each county.
#'
#' @details Some counties cover more than one time zone designation. For
#' example, parts of Coconino, Navajo, and Apache Counties in Arizona
#' follow Daylight Savings Time, while other parts of the county do not. We
#' tried to designate county-level time zones based on the time zone used in
#' the majority of the county, based on county land area. When aggregating from
#' multiple monitors in a county, the time zone should be left in UTC until data
#' is aggregated, then the final value can be converted to local time, rather
#' than converting to local time before aggregating across a county.
#'
#' Currently, the dataset does not destinguish between the time zone
#' designations "America/Anchorage" and "America/Nome". If you are using this
#' dataset for applications where local times may differ between these two
#' designations, you should take care to ensure you are getting reasonable
#' results.
#'
#' @format A dataframe with 3,143 rows and 4 variables:
#' \describe{
#'   \item{fips}{A numeric vector giving the county's four- or five-digit
#'               Federal Information Processing Standard (FIPS) code}
#'   \item{tz}{A character vector with the county's Olson/IANA time zone
#'             designation}
#'   \item{county}{A character vector giving the county's name}
#'   \item{state}{A character vector giving the county's state}
#' }
#'
#' @source
#'
#' \url{http://www.statoids.com/tus.html}
#'
#' \url{http://efele.net/maps/tz/us/}
#'
#' @seealso \code{\link{OlsonNames}}
"county_tzs"

#' Date-times for Hurricane Floyd
#'
#' A dataframe that gives the date-time, in Coordinated Universal Time (UTC),
#' for when Hurricane Floyd was closest to each county in the Eastern United
#' States.
#'
#' @format: A dataframe with 2,396 rows and 2 variables:
#' \describe{
#'  \item{fips}{A numeric vector giving the county's four- or five-digit
#'               Federal Information Processing Standard (FIPS) code}
#'  \item{closest_time_utc}{The date and time, in UTC, when Hurricane Floyd
#'                          was closest to the county (based on a storm
#'                          track interpolated to 15 minute observations)}
#' }
#'
#' @source
#'
#' https://github.com/geanders/hurricaneexposure/tree/master/data
"floyd"
