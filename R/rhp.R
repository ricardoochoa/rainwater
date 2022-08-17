#' Rainwater harvesting preheating. Calculate a rain harvesting system performance using daily rainfall data and n amount of "preheat" years.
#'
#' @description
#' Runs the function rhq `n` amount of times. In each iteration, the tank level `tlevel` of the last day of the year is passed as an initial tank level `initial.level` for the first day of the following year.
#'
#' @param p numeric vector with daily precipitation in milimeters.
#' @param area numeric vector of the rainwater catchment area in m2.
#' @param holidays numeric vector with water consumption (1) such as a weekday in an office, or days without significant water consumption (0), such as a weekend in an office.
#' @param tank.size numeric vector with the water storage capacity in liters.
#' @param users numeric vector with the amount of persons using water.
#' @param use numeric vector with the daily per capita water demand in liters.
#' @param filter.coefficient numeric vector with the fraction of the water that can be used after the filtering process (default 0.90). Typical values are 0.90 for personal hygiene or drinking water and 0.95 for other uses such as WC or irrigation.).
#' @param keep.options logical vector specifying if the tank size should be stored as a variable in the output (default FALSE).
#' @param n number of iterations (default 3).
#'
#' @return
#' Dataframe (same number of rows as lenght of p) with daily estimates of precipitation, activity, water demand, rainwater supply, used rainwater, tank level, and wasted water.
#'
#' @examples
#' # Rainwater harvesting estimation performance values for a rainwater harvesting system,
#' # considering a daily precipitation of 10 mm and a catchment area of 100 m2.
#' rhp(p = rep(10, 365), area = 100)
#' # Repeat the calculations but this time with 4 iterations.
#' rhp(p = rep(10, 365), area = 100, n = 4)
#'
#' @import plyr
#'
#' @export
rhp <- function(
    p,
    area,
    holidays = 1,
    tank.size = 450,
    users = 4,
    use = 50,
    filter.coefficient = 0.9,
    keep.options = FALSE,
    n = 3
){
  F_TLEVEL <- 0 # create an object for the default initial tank water level value.
  TEMP <- list() # create a list object for saving the results.

  # Runs the `rhq` function `n` times considering the final tank water level value of each run
  for(r in 1:n){ # determine that the process should run n times.
    TEMP <- rhq(p = p,
                area = area,
                holidays = holidays,
                tank.size = tank.size,
                users = users,
                use = use,
                filter.coefficient = filter.coefficient,
                initial.level = F_TLEVEL,
                keep.options = keep.options) # determine the initial tank water level

    F_TLEVEL = TEMP[nrow(TEMP), "tlevel"]                 # as the default value or the final tank
    # water level value of the last run.
  }
  return(TEMP)
}
