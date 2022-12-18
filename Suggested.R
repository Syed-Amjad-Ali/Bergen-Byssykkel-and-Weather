library(tidyverse)
library(dplyr)
library(ggplot2)
library(lubridate)
library(openair)
library(zoo)


#reading and cleaning cycle data-----------------
df<-read.csv("01.csv")
load("df_agg.RData")





unique(df$started_at)
count(df$started_at)
dates <- as.Date(df$started_at, '%d/%m/%Y') #this did not work
#
yr <- year(dates)
monyr <- as.yearmon(dates)
lst <- lapply(list(dates, yr, monyr), function(x) #i am not sure what happened here
  transform(df, Count=ave(seq_along(x), x, FUN= length)))
names(lst) <- paste0('newdf', seq_along(lst))
list2env(lst, envir=.GlobalEnv)
#

counts <- data.frame(table(as.Date(index(df))))#don't know what happened here

#
df %>% group_by(year=year(started_at)) %>% count()
df %>% group_by(year=year(started_at), month=month(started_at)) %>% count()





#reading and cleaning weather data--------

weather<- read_csv("weather_data.csv")#need to figure out, how to clean this one

read_csv("preci.csv")

#this didn't work
shananigan<-
  weather %>% unnest_wider(`Name;Station;Time(norwegian mean time);Precipitation (24 h);Average of mean wind speed from main obs. (24 h);Mean air temperature (24 h)`)
#this didn't work

shananigan <- read.csv(file = "weather_data.csv", head = TRUE, sep=",")


shananigan<-   #this seems a very brute way of renaming columns, but i tried quite a few things :3                   


#now i will just make new data frame of with the necessary variables only

#new_df<- Day_wise_count %>% select(-year)

#need to figure shit out
#Reg_Data<-
#left_join(Day_wise_count,shananigan,by=character())#i am done f-d up, cause i need to fix shananigan dates first

shananigan %>% group_by(year=year(Time), 
                month=month(Time), 
                day=day(Time)) %>% count()

#
as.Date(as.numeric(as.character(shananigan$Time)), origin='01.01.2021')
#
shananigan$Time<- as.numeric(as.character(shananigan$Time)) 
shananigan$Time# does not work


shananigan$Time<-as.character.POSIXt(shananigan$Time)

shananigan %>%
            group_by(year=year(Time), 
             month=month(Time), 
             day=day(Time))

shananigan<- as.data.frame(shananigan)








## nice, now we have our required data fram
#there are quite a few bummers in here, say the dates are f-d up

ggplot(y,aes(x=temperature,y=count))+geom_point()

reg_result<-(lm(count~temperature+wind+precipitation,y))
summary(reg_result)


#
#so lets fix things up
#lets, come back and clean everything . 
#first, read the data in two separate data frame.
#fix the format, don't change date to numeric
#if possible, merge the data set, remember to delete 366th from weather
#try to plot and regress data



#################

df <-
  list.files(path="data/", pattern = ".csv", full.names = T) %>% #we used list files to detect all csv files
  map_df(~read_csv(.)) #we used map function to iterate over all csv files in our folder
#we now have a huge ass list, which would need a lot of cleaning

df %>% group_by(year=year(started_at), month=month(started_at), day=day(started_at)) %>% count()
##Aha!!! This works i guess


Day_wise_count<- df %>% group_by(year=year(started_at), 
                                 month=month(started_at), 
                                 day=day(started_at)) %>% count()


shananigan <- read.csv(file = "weather_data.csv", skip = 1, 
                       head = FALSE, sep=";")

shananigan<- shananigan %>% 
  rename("Name"="V1","Station"="V2","Time"="V3","Precipitation"="V4",
         "Wind"="V5","Temperature"="V6")

shananigan<-shananigan[-366,]

shananigan$Time <- dmy(shananigan$Time) # alright finally this shit turned the dates into proper format





y <- data.frame(matrix(ncol = 5, nrow = 365))
x <- c("day", "count", "precipitation","wind","temperature")
colnames(y) <- x
y$day<-shananigan$Time
#y$day<-dmy(y$day)  apparently this does not work now
y$count<-Day_wise_count$n
y$precipitation<-shananigan$Precipitation
y$wind<-shananigan$Wind
y$temperature<-shananigan$Temperature

ggplot(y,aes(x=wind,y=count))+geom_point()

summary(lm(count~temperature,y))
# not needed for now weekdays_label <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

#y$day <- weekdays(as.Date(y$day))

y<-
mutate(y,"weekdays"=weekdays(as.Date(y$day))) #fantastic! nice! jhakas! ekdam jhakas!https://www.youtube.com/shorts/EhLZrhuyeeI

y<- y %>% relocate(weekdays,.after = day)

XYZ<- #i am so sexy with dummies  
  ifelse(y$weekdays=="Saturday"|y$weekdays=="Sunday",1,0) #here we create our beautiful dummy variable :)


y<-mutate(y,"dummy"=XYZ)
y<- y %>% relocate(dummy,.after = weekdays)

regressions<-
summary(lm(count~precipitation+wind+temperature+dummy,data=y))

## nice, from here we just follow along what we learnt in class