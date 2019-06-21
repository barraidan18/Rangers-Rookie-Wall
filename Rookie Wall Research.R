#load necessary packages
install.packages('odbc')
install.packages('rstudioapi')
library(odbc)
library(DBI)
library(dplyr)
library(tidyr)
library(ggplot2)
install.packages("RPostgreSQL")
require(RPostgreSQL)

# establish a connection to the SQL database

pwd <- "Rangers7622"

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, dbname= "aidanbarr", host = "localhost", port = 5432, user = "aidanbarr", password = pwd)

#check for tables

dbExistsTable(con, "chytil_gamelog_2018")
dbExistsTable(con, "howden_gamelog_2018")
dbExistsTable(con, "l_andersson_gamelog_2018")

# import tables and save then as R data frames
#Chytil first
chytil <- dbGetQuery(con, "SELECT game_date, game, goals, assists, points, ev_goals, pp_points AS pp_goals, ev_assists, pp_assists, shots_on_goal AS sog, ice_time, player
                     FROM chytil_gamelog_2018")
head(chytil)
chytil <- as_tibble(chytil)

#now Howden

howden <- as_tibble(dbGetQuery(con, "SELECT game_date, game, goals, assists, points, ev_goals, pp_points AS pp_goals, ev_assists, pp_assists, shots_on_goal AS sog, ice_time, player
                     FROM howden_gamelog_2018"))

#now Andersson

andersson <- as_tibble(dbGetQuery(con, "SELECT game_date, game, goals, assists, points, ev_goals, pp_points AS pp_goals, ev_assists, pp_assists, shots_on_goal AS sog, ice_time, player
                     FROM l_andersson_gamelog_2018"))

#make ice time into a date

library(purrr)
library(lubridate)

#for Chytil

chytil$ice_time <- ms(chytil$ice_time) 

typeof(andersson$ice_time)

chytil$ice_time <- as.duration(chytil$ice_time)

head(chytil$ice_time)

chytil$ice_time <- as.numeric(chytil$ice_time)

head(chytil$ice_time)

#for howden

howden$ice_time <- ms(howden$ice_time)

howden$ice_time <- as.duration(howden$ice_time)
howden$ice_time <- as.numeric(howden$ice_time)
head(howden$ice_time)

#for andersson

andersson$ice_time <- ms(andersson$ice_time)
andersson$ice_time <- as.duration(andersson$ice_time)
andersson$ice_time <- as.numeric(andersson$ice_time)
head(andersson$ice_time)

#manipualte the data to add columns for per 60 mins scoring rates

View(andersson)
andersson2 <- andersson %>% mutate(cumu_g = cumsum(goals),
                                   cumu_a = cumsum(assists),
                                   cumu_p = cumsum(points),
                                   cumu_toi = cumsum(ice_time),
                                   avg_p60 = (cumu_p/cumu_toi)*3600,
                                   avg_g60 = (cumu_g/cumu_toi)*3600,
                                   avg_a60 = (cumu_g/cumu_toi)*3600)
chytil2 <- chytil %>% mutate(cumu_g = cumsum(goals),
                                   cumu_a = cumsum(assists),
                                   cumu_p = cumsum(points),
                                   cumu_toi = cumsum(ice_time),
                                   avg_p60 = (cumu_p/cumu_toi)*3600,
                                   avg_g60 = (cumu_g/cumu_toi)*3600,
                                   avg_a60 = (cumu_g/cumu_toi)*3600)
howden2 <- howden %>%
  arrange(game) %>%
  mutate(cumu_g = cumsum(goals),
         cumu_a = cumsum(assists),
         cumu_p = cumsum(points),
         cumu_toi = cumsum(ice_time),
         avg_p60 = (cumu_p/cumu_toi)*3600,
         avg_g60 = (cumu_g/cumu_toi)*3600,
         avg_a60 = (cumu_g/cumu_toi)*3600)
#plot game vs the rolling average of points per 60 mins for each player

ggplot(andersson2, aes(x = game, y = avg_p60)) + geom_point(color = "blue") + geom_line(aes(group = 1), color = "blue") + xlab("Game Number") + ylab("Points Per Hour") + ggtitle("Lias Andersson: Points Per Hour Rolling Average by Game") + theme_bw() + theme(plot.title = element_text(size = 10))
ggplot(chytil2, aes(x = game, y = avg_p60)) + geom_point(color = "blue") + geom_line(aes(group = 1), color = "blue") + xlab("Game Number") + ylab("Points Per Hour") + ggtitle("Filip Chytil: Points Per Hour Rolling Average by Game") + theme_bw() + theme(plot.title = element_text(size = 10))
ggplot(howden2, aes(x = game, y = avg_p60)) + geom_point(color = "blue") + geom_line(aes(group = 1), color = "blue") + xlab("Game Number") + ylab("Points Per Hour") + ggtitle("Brett Howden: Points Per Hour Rolling Average by Game") + theme_bw() + theme(plot.title = element_text(size = 10))

#plot points as steps

ggplot(andersson2, aes(x = game, y = cumu_p)) + geom_step(aes(group = 1), color = "blue") + xlab("Game Number") + ylab("Points") + ggtitle("Lias Andersson: Points") + theme_bw() + theme(plot.title = element_text(size = 10))
ggplot(howden2, aes(x = game, y = cumu_p)) + geom_step(aes(group = 1), color = "blue") + xlab("Game Number") + ylab("Points") + ggtitle("Brett Howden: Points") + theme_bw() + theme(plot.title = element_text(size = 10))
ggplot(chytil2, aes(x = game, y = cumu_p)) + geom_step(aes(group = 1), color = "blue") + xlab("Game Number") + ylab("Points") + ggtitle("Filip Chytil: Points") + theme_bw() + theme(plot.title = element_text(size = 10))

#Time for changepoint regression to see if there is a statistically significant relationship
#Lias Andersson is the only rookie who's trend seems to follow the idea of a rookie wall
#Only Lias Anderssons points per 60 minutes will recieve changepoint regression

install.packages("changepoint")
library(changepoint)

?changepoint

#First make Anderssons Points Per Hour a time series
#Then use the "PELT" method to determine if there are any significant changes in mean


andscoring.ts <- ts(andersson2$avg_p60)
andmean <- cpt.mean(andersson2$avg_p60, method = "PELT")
andmean
plot(andmean, main = "Lias Andersson: Points Per Hour Mean", xlab = "Game Number", ylab = "Points Per Hour Rolling Average")

#since none were found with the "PELT" method we need to use the Binary Segments method to be sure

andmean <- cpt.mean(andersson2$avg_p60, method = "BinSeg")
andmean
plot(andmean)

#No changes in mean
#Now Variance

andvar <- cpt.var(andersson2$avg_p60, method = "PELT")
andvar
plot(andvar)

andvar <- cpt.var(andersson2$avg_p60, method = "BinSeg")
andvar
plot(andvar, main = "Lias Andersson: Points Per Hour Variance", xlab = "Game Number", ylab = "Points Per Hour Rolling Average")

#There were two significant changes in variance for Lias Andersson and they were the same for both methods
#Conclusion: There was a change in variance but the variance of Andersson's scoring is not really part of the rookie wall idea




