#' Summarize rainwater harvesting results
#'
#' @description
#' Gets x, the output from rhq or rhp and the year
#'
#' @param x data frame object
#' @param year character vector of the year
#'
#' @return
#' List with 1 dataframe (12 rows) of monthly estimates of demanded and used rainwater, and 2 numeric vectors of water demand percentage covered with rain and liters used in the year.
#'
#' @import lubridate
#' @import plyr
#'
#' @examples
#' rh_performance <- rhp(p = rep(0.5, 366), area = 100)
#' summarize_rh(rh_performance)
#'
#' @export
summarize_rh <- function(x, year = "2020"){

  calendar <- seq(as.Date(paste0(year, "-01-01")), as.Date(paste0(year, "-12-31")), by="days") # create an object with all the dates of the year.

  x$date = calendar # add a column of the dates of the year to the x parameter data frame.

  x$m <- lubridate::month(x$date) # add a column of the numbers of each month to the x parameter data frame.

  # Create a list with all the results
  TEMP <- list() # save the list in the object "TEMP".

  # Summarize water use and demand for each month
  TEMP$monthly_summary <- stats::aggregate(cbind(x$usedrw, x$demand)~x$m, FUN = sum)
  names(TEMP$monthly_summary) <- c("month", "supply", "demand")
  TEMP$monthly_summary$percentage <- 100 * TEMP$monthly_summary$supply / TEMP$monthly_summary$demand

  TEMP$rain_percentage <- paste(round(100*sum(x$usedrw)/sum(x$demand), 0), "%")
  # calculate and add the percentage
  # of demand covered with rainwater.
  TEMP$rain_volume <- paste(formatC(sum(x$usedrw), format = "d", big.mark=","), " L/year")
  # calculate and add the total volume
  # of rainwater harvested in the year.

    return(TEMP)

}
