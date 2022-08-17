#' Rainwater harvesting optimization. Calculate the rainwater used in a rain harvesting system at different tank sizes
#'
#' @description
#' Runs the `rhp` function for a list of tank storage volume options.
#'
#' @param p numeric vector with daily precipitation in milimeters.
#' @param area numeric vector of the rainwater catchment area in m2.
#' @param holidays numeric vector with water consumption (1) such as a weekday in an office, or days without significant water consumption (0), such as a weekend in an office.
#' @param tank.size numeric list with the water storage capacity in liters of one or more tank options.
#' @param users numeric vector with the amount of persons using water.
#' @param use numeric vector with the daily per capita water demand in liters.
#' @param filter.coefficient numeric vector with the fraction of the water that can be used after the filtering process (default 0.90). Typical values are 0.90 for personal hygiene or drinking water and 0.95 for other uses such as WC or irrigation.).
#' @param n number of iterations (default 3).
#'
#' @return
#' Dataframe (same number of rows as lenght of p) with daily estimates of precipitation, activity, water demand, rainwater supply, used rainwater, tank level, and wasted water for each tank option.
#'
#' @examples
#' # Rainwater harvesting estimation performance values for a rainwater harvesting system,
#' # considering a daily precipitation of 10 mm and a catchment area of 100 m2.
#' rho(p = rep(10, 365), area = 100, tank.size = list(450, 1000, 2000))
#'
#' @import plyr
#'
#' @export
rho <- function(
    p,
    area,
    holidays = 1,
    tank.size = list(450),
    users = 4,
    use = 50,
    filter.coefficient = 0.9,
    n = 3
){

 TEMP <- lapply(X = tank.size, FUN = function(X){rhp(p = p,
                                              area = area,
                                              holidays = holidays,
                                              tank.size = X,
                                              users = users,
                                              use = use,
                                              filter.coefficient = filter.coefficient,
                                              n = n,
                                              keep.options = TRUE)})

  TEMP <- do.call(rbind, TEMP)

  return(TEMP)
}
