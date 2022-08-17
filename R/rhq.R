#' Rainwater harvesting quantification. Calculate a rain harvesting system performance using daily rainfall data.
#'
#' @description
#' Generates a results list of data related to rainwater demand, supply, and use at a rain harvesting system, using
#' daily rainfall data and other particular inputs parameters.
#'
#' @param p numeric vector with daily precipitation in milimeters.
#' @param area numeric vector of the rainwater catchment area in m2.
#' @param holidays numeric vector with water consumption (1) such as a weekday in an office, or days without significant water consumption (0), such as a weekend in an office.
#' @param tank.size numeric vector with the water storage capacity in liters.
#' @param users numeric vector with the amount of persons using water.
#' @param use numeric vector with the daily per capita water demand in liters.
#' @param filter.coefficient numeric vector with the fraction of the water that can be used after the filtering process (default 0.90). Typical values are 0.90 for personal hygiene or drinking water and 0.95 for other uses such as WC or irrigation.).
#' @param initial.level numeric vector of the initial tank water level in liters (default 0).
#' @param keep.options logical vector specifying if the tank size should be stored as a variable in the output (default FALSE).
#'
#' @return
#' Dataframe (same number of rows as lenght of p) with daily estimates of precipitation, activity, water demand, rainwater supply, used rainwater, tank level, and wasted water.
#'
#' @examples
#' # Rainwater harvesting estimation performance values for a rainwater harvesting system,
#' # considering a daily precipitation of 10 mm and a catchment area of 100 m2.
#' rhq(p = rep(10, 365), area = 100)
#' # Repeat the calculations with custom parameters: a tank vlume of 1000L,
#' # a filter coefficient of 0.95, and
#' # 3 users with a daily demand of 100L per capita.
#' rhq(p = rep(10, 365), area = 100,
#'     holidays = 1, tank.size = 450, users = 4,
#'     use = 50, filter.coefficient = 0.9)
#'
#' @import plyr
#'
#' @export
rhq <- function(
    p,
    area,
    holidays = 1,
    tank.size = 450,
    users = 4,
    use = 50,
    filter.coefficient = 0.9,
    initial.level = 0,
    keep.options = FALSE
){
  # Create a data frame with holidays and precipitation data
  system_performance <- data.frame(p = p, holidays = holidays)

  # Calculate total daily water demand
  system_performance$demand <- users * #create a column of water demand
    use *           #by multiply the number of users per daily per.
    system_performance$holidays          #capita water demand and the active days of the year.

  # Calculate daily harvested rainwater
  system_performance$supply <- area * (100) * #convert m2 of the catchment area to dm2.
    system_performance$p * (1/100) * # convert mm of precipitation to dm.
    filter.coefficient * 0.8 # assumption: runoff coefficient is always 0.8.

  # Initialize variables
  system_performance$usedrw <- 0 # create a column of daily rainwater use.
  system_performance$tlevel <- 0 # create a column of daily tank water level.
  system_performance$wasted.water <- 0 # create a column of daily rainwater wasted.

  # Calculate rainwater levels for the first day (row 1)
  c <- 1
    system_performance$usedrw[c]       <- min(tank.size,               # calculate rainwater used as the min value between
                                              system_performance$demand[c],   # the tank storage volume, the daily water demand
                                              initial.level +          # in this row and the sum of the initial tank water
                                                system_performance$supply[c]) # level and the daily rainwater supply at this row.

    system_performance$wasted.water[c] <- max(0,                        # calculate rainwater wasted as the max value between
                                              initial.level +           # 0 and the sum of the initial tank water level and the
                                                system_performance$supply[c] - # daily rainwater supply in this row minus the rainwater
                                                system_performance$usedrw[c] - # used in this row and the tank storage volume.
                                                tank.size)

    system_performance$tlevel[c]       <- max(0,                        # calculate tank water level as the max value between
                                              initial.level +           # 0 and the sum of the initial tank water level and the
                                                system_performance$supply[c] - # daily rainwater supply in this row minus the rainwater
                                                system_performance$usedrw[c] - # used and wasted in this row.
                                                system_performance$wasted.water[c])
  rm(c)

  # Calculate rainwater levels for the rest of the days (rows 2:365)
  for(c in 2:nrow(system_performance)){ # determine this process from row 2 to the remaining number of rows in the data frame.

    system_performance$usedrw[c]       <- min(tank.size,                # calculate rainwater used as the min value between
                                              system_performance$demand[c],    # the tank storage volume, the daily water demand in
                                              system_performance$tlevel[c-1] + # this row and the sum of the previous row tank water
                                                system_performance$supply[c])   # level and the daily rainwater supply at this row.

    system_performance$wasted.water[c] <- max(0,                        # calculate rainwater wasted as the max value between
                                              system_performance$tlevel[c-1] + # 0 and the sum of the the previous row tank water level
                                                system_performance$supply[c] - # and the daily rainwater supply in this row minus the
                                                system_performance$usedrw[c] - # rainwater used in this row and the tank storage volume.
                                                tank.size)

    system_performance$tlevel[c]       <- max(0,                        # calculate tank water level as the max value between
                                              system_performance$tlevel[c-1] + # 0 and the sum of the previous row tank water level
                                                system_performance$supply[c] - # and the daily rainwater supply in this row minus
                                                system_performance$usedrw[c] - # the rainwater used and wasted in this row.
                                                system_performance$wasted.water[c])

    if(keep.options){system_performance$tank.size <- tank.size}
  }

  return(system_performance)

}
