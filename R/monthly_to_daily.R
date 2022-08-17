#' Estimate the year's daily precipitation from average monthly values.
#'
#' @description
#' Gets a vector of length 365 (or 366 if the selected year is leap-year) with daily precipitation data and a year.
#'
#' @param p numeric vector of length 12 corresponding to average millimeters of precipitation for each month.
#' @param year character vector of the year
#'
#' @return
#' Vector of length 365 or 366 with daily precipitation data.
#'
#' @import lubridate
#' @import plyr
#' @import stats
#'
#' @examples
#' # example 1:
#' monthly_to_daily(p = c(4, 10, 12, 14, 17, 22, 10, 24, 20, 12, 11, 6), year = "2020")
#' # example 2:
#' rhq(p = monthly_to_daily(p = c(4, 10, 12, 14, 17, 22, 10, 24, 20, 12, 11, 6),
#'                          year = "2020"),
#'                          area = 100)
#'
#' @export
monthly_to_daily <- function(p, year = "2020"){
  data_monthly <- data.frame( # create a data frame with average monthly precipitation
    p = p,                    # values and months number corresponding to each value.
    m = 1:12)

  data_daily <- data.frame(date = seq(as.Date(paste0(year, "-01-01")), # create data frame of all the
                                      as.Date(paste0(year, "-12-31")), # dates of the selected year.
                                      by="days"))


  data_daily$m <- lubridate::month(data_daily$date) # add a column with the months number of each date
  data_daily$d <- 1

  days_in_month <- stats::aggregate(d~m, FUN = sum, data = data_daily)
  data_daily$d <- NULL

  data_daily <- merge(days_in_month, data_daily)
  data_daily <- merge(data_monthly, data_daily)

  data_daily$p <- data_daily$p / data_daily$d

  return(data_daily$p) # get p values for each date
}
