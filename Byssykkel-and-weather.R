library(magrittr)
library(dplyr)
library(readr)
library(data.table)
library(assertthat)
library(rsample)
library(purrr)
library(tidyverse)
library(ggmap)
library(leaflet)
############
#Download data for January 2021 in both .json and .csv-format. Use the lines below to load in the data frame from the .csv:

df_202401_csv <- read_csv("byssykkel-data-2024/01.csv") %>% 
  mutate(across(c("start_station_latitude", "start_station_longitude", "end_station_latitude", "end_station_longitude"), function(x) signif(x, digits=15)))
dim(df_202401_csv)



#Read in all bike rides from 01 Jan 2024 to 8 Dec 2024
# Get a List of all files in directory named with a key word, say all `.csv` files
filenames <- list.files("byssykkel-data-2024", pattern=".csv", full.names=TRUE)
# read and row bind all data sets
bike_rides_2024_data <- rbindlist(lapply(filenames,fread))


#Make a combination of observations for every station, date and hour of day.

start_station_id = as.double(unique(bike_rides_2024_data$start_station_id))

floor_start_dh <- seq(as.POSIXct("2024-01-01 00:00:00"), as.POSIXct("2024-12-19 23:00:00"), by = "hours")

df <- 
  expand.grid(floor_start_dh, start_station_id) %>%
  rename(floor_start_dh = Var1,
         start_station_id = Var2) %>% 
  arrange(start_station_id)
head(df,10)


# Count of rides for each hour 
bike_rides_2024 <- bike_rides_2024_data %>% 
  mutate(start_date = format(as.POSIXct(.$started_at, '%Y-%m-%d %H:%M:%S'), '%Y-%m-%d %H:%00:%00')) %>% 
  group_by(start_station_id, start_date) %>%
  summarise(n_rides = n())
# Change the class of start_date into date type (instead of character)
bike_rides_2024$start_date <- as.POSIXct(bike_rides_2024$start_date )
bike_rides_2024


##join the data and fill the NA value (no ride in that hour) as "0"
df_agg <- left_join(df, bike_rides_2024, by = c("start_station_id" = "start_station_id", "floor_start_dh" = "start_date"))
df_agg [is.na(df_agg )] <- 0


## create weekday start as 1-> 7 (Sunday=1 to Saturday=7), start_hour as 0 -> 23
df_agg <- df_agg %>% 
  mutate(start_hour=as.factor(hour(floor_start_dh)),weekday_start=as.factor(wday(floor_start_dh)))
head(df_agg,10)

#Name the data set df_agg and show that the data set passes 2 tests below:
#Test 1
assert_that(df_agg %>%
              group_by(start_station_id, floor_start_dh) %>%
              summarise(n = n()) %>%
              ungroup() %>%
              summarise(max_n = max(n)) %$%
              max_n == 1,
            msg = "Duplicates on stations/hours/dates")
#Test 2
assert_that(df_agg %>%
              group_by(start_station_id) %>%
              mutate(
                timediff = floor_start_dh - lag(floor_start_dh,
                                                order_by = floor_start_dh)
              ) %>%
              filter(as.numeric(timediff) != 1) %>%
              nrow(.) == 0,
            msg="Time diffs. between obs are not always 1 hour")


##Problem 3:
##(a) Estimate a linear regression model for each of the stations. 
#Using factors for weekdays and hour of day as explanatory variables 
#and n_rides as the response variable. Determine the exact specification 
#as you see fit.

# Split input data into train set and test set (grouped by station id, train/test ratio is 3/1)
by_station <- df_agg %>% group_by(start_station_id) %>% 
  summarize(split = list(initial_time_split(cur_data()))) %>%
  group_by(start_station_id) %>% 
  mutate(data.train=list(training(split[[1]])),data.test=list(testing(split[[1]]))) %>%
  select(!split)
by_station



map(setNames(by_station$data.train, by_station$start_station_id)[1:2], summary)


map(setNames(by_station$data.test, by_station$start_station_id)[1:2], summary)




## A function that fits the linear regression model to each station
station_model <- function(df) {
  lm(n_rides~weekday_start + start_hour, data=df)
}
# put the linear model to each station by using purrr:map() to apply the model to each element
models <- map(by_station$data.train, station_model)
# Put the model inside a mutate
by_station <- by_station %>%
  group_by(start_station_id) %>%
  mutate(model = map(data.train, station_model)) %>% 
  ungroup()
by_station



## Check models of station 2 and station 3
by_station %>% 
  filter(start_station_id == 2) %>% 
  pluck("model", 1) %>% 
  summary()

by_station %>% 
  filter(start_station_id == 3) %>% 
  pluck("model", 1) %>% 
  summary()



##(b) Predict the number of rides for each hour of day, 
#weekday and station using these regression models. 
#Collect the predictions in a data structure, together with the station ID.


by_station <- by_station %>%
  group_by(start_station_id) %>%
  mutate(predictions = list(predict(model[[1]], newdata=data.test[[1]]))) %>%
  ungroup()
by_station



prediction_df_from_station_nr <- function(station_nr) {
  by_station %>%
    filter(start_station_id == station_nr) %>%
    ungroup() %>%
    select(c(data.test, predictions)) %>%
    unnest(c(data.test, predictions)) %>%
    mutate(start_station_id = station_nr)
}



predictions_from_all_stations <- bind_rows(map(by_station$start_station_id, prediction_df_from_station_nr))
predictions_from_all_stations



##(c) Create a set of plots showing the predicted number of bicycle rides throughout an entire week.
#Place predicted volume on the y-axis and the hour of day on the x-axis. 
#Make one plot per day of week. Use different colors for each station, 
#and format the plots as appropriate.


predictions_from_all_stations %>%
  filter(floor_start_dh > "2024-10-01 00:00:00", floor_start_dh <= "2024-10-08 00:00:00") %>%
  ggplot(aes(x = as.numeric(start_hour), y = predictions, color = factor(start_station_id))) +
  geom_line() +
  labs(
    x = "Start Hour",
    y = "Predictions",
    colour = "Start Station ID",
    title = "Hourly Bicycle Ride Count Prediction Per Station from 2024-10-01 to 2024-10-07"
  ) + 
  facet_wrap(vars(weekday_start), scales = "fixed", ncol = 1)




##### Problem 4:
#   Create a function with the following specifications
# 
# • The function should, as a minimum, take as arguments the date and the hour.
# 
# • The function should return a plot with the following properties:
#   
#   – The latitude and the longitude should be mapped to the x and the y-axis respectively.
# 
# – The plot should give information about the traffic volume (or predicted traffic volume) for each of the stations in the data set at the given time.
# 
# – The plot should be well formatted.
# 
# Note that the latitude and longitude of the stations may change over time. Use your best judgement to overcome this problem in order to make a figure that informs the reader of where bicycle traffic is originating from in Bergen at given times.



# The latitude and longitude of the stations may change over time -> calculate the average lon and lat of each station through time
station  <- bike_rides_2024_data %>% 
  select(start_station_id, start_station_longitude, start_station_latitude) %>% 
  group_by(start_station_id) %>% 
  summarise(lon = sum(start_station_longitude)/n(), lat = sum(start_station_latitude)/n())
station


# join data of lon and lat of each station into the df_agg
df_agg_lonlat <- left_join(df_agg, station , by = c("start_station_id" = "start_station_id"))

head(df_agg_lonlat,10)


#Create a function
plot_map_leaflet <- function(date_and_hour) {
  df <- df_agg_lonlat %>%
    filter(floor_start_dh == date_and_hour)
  
  # Define distinct colors for small and larger ranges of bike rides
  ride_colors <- colorFactor(
    palette = c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3", "#ff7f00", "#ffff33"), # Added a color for >4
    levels = c(0, 1, 2, 3, 4, "5+"),  # Add a category for "5+"
    na.color = "black"
  )
  
  # Create a new column for categorized rides
  df <- df %>%
    mutate(
      ride_category = case_when(
        n_rides <= 4 ~ as.character(n_rides),
        n_rides > 4  ~ "5+"  # Group all rides >4 into "5+"
      )
    )
  
  leaflet(df) %>%
    addTiles() %>%  # Adds OSM tiles
    addCircleMarkers(
      lng = ~lon,
      lat = ~lat,
      radius = ~ifelse(n_rides > 0, n_rides * 3, 5),  # Scaled marker size, minimum size for 0 rides
      color = ~ride_colors(ride_category),  # Apply distinct colors based on ride_category
      label = ~paste("Station ID:", start_station_id, "<br>",
                     "Rides:", n_rides),  # Tooltip for hover
      popup = ~paste("<strong>Station ID:</strong>", start_station_id, "<br>",
                     "<strong>Number of Rides:</strong>", n_rides, "<br>",
                     "<strong>Time:</strong>", date_and_hour)  # Detailed popup
    ) %>%
    addLegend(
      "bottomright",
      pal = ride_colors,
      values = c(0, 1, 2, 3, 4, "5+"),
      title = paste("Rides on", date_and_hour),  # Dynamic title
      opacity = 1
    ) %>%
    addScaleBar(position = "bottomleft") %>%
    addMiniMap(toggleDisplay = TRUE) %>%
    addControl(
      html = paste("<h4>Bicycle Traffic Volume at", date_and_hour, "</h4>"),
      position = "topright"
    )
}

    


# Test the plot with a specific date and hour
plot_map_leaflet("2024-06-08 13:00:00")


##
plot_map_leaflet("2024-05-18 15:00:00")

#########Combining Weather Data



# Load the dataset
df5 <- read_csv("Bergen_data_best.csv", col_names = FALSE)

# Split the first column and clean the dataset in one step
df5_cleaned <- df5 %>%
  # Split the first column into multiple columns
  separate(
    col = X1,  # Assuming the main data is in column X1
    into = c(
      "Name",
      "Station",
      "Date",
      "MeanWindSpeed_24h",
      "Precipitation_24h",
      "MeanAirTemperature_24h",
      "SnowDepth",
      "MeanRelativeHumidity_24h"
    ),
    sep = ";",
    convert = TRUE  # Automatically convert numeric columns
  ) %>%
  # Remove redundant columns (X2 to X6)
  select(-c(X2, X3, X4, X5, X6)) %>%
  # Remove the metadata row (first row) if it exists
  slice(-1) %>%
  # Convert columns to their proper types
  mutate(
    Date = as.Date(Date, format = "%d.%m.%Y"),  # Convert Date to Date type
    MeanWindSpeed_24h = as.numeric(MeanWindSpeed_24h),
    Precipitation_24h = as.numeric(Precipitation_24h),
    MeanAirTemperature_24h = as.numeric(MeanAirTemperature_24h),
    SnowDepth = as.numeric(SnowDepth),
    MeanRelativeHumidity_24h = as.numeric(MeanRelativeHumidity_24h)
  )

# View the structure and the first few rows of the cleaned dataset
str(df5_cleaned)
head(df5_cleaned)