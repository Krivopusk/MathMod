#Кривопуск 132 Задание 1
#для региона 4 (Республика Алтай) рассчитайте урожайность пшеницы в 2017 году,
#взяв для рассчета средние суммы активных температур за предыдущие 7 лет, с 21 ближайших метеостанций
library(dplyr)
library(tidyverse)
library(rnoaa)

station_data = ghcnd_stations()
write.csv(station_data,file="station_data.csv")
station_data=read_csv("station_data.csv")

altai=data.frame(id = "Altai", latitude = 51.576336,  longitude = 85.551352)
altai_around = meteo_nearby_stations(lat_lon_df = altai, station_data = station_data,limit = 21, var = c("PRCP", "TAVG"),year_min = 2009, year_max = 2016)
 
altai_id=altai_around$Altai$id
all_altai_data = meteo_tidy_ghcnd(stationid = altai_id)

all_altai_data$date
all_altai_data = all_altai_data %>% mutate (
  year=year(date),
  month=month(date),
  day=yday(date)
)
all_altai_data=all_altai_data %>% select (id, year ,month ,day, tavg, tmin, tmax)

all_altai_data=all_altai_data %>% mutate(
  tavg=tavg/10,
  tmin=tmin/10,
  tmax=tmax/10
)
all_altai_data=all_altai_data %>% mutate(
  tavg = case_when(
    is.na(tavg) ~ 0,
    tavg < 5 ~ 0,
    TRUE ~ tavg
  ))
all_altai_data=all_altai_data %>% filter (
  year >= 2009,
  year <= 2016
)
alldays =  group_by( all_altai_data , id , year , month )

sumT_alldays_altai =  summarize( alldays ,  tsum =  sum( tavg ))
summary( sumT_alldays_altai )

groups_altai_months =  group_by( sumT_alldays_altai , month ) 
sumT_months =  summarize( groups_altai_months  ,  St =  mean( tsum ))
sumT_months

#Расчеты 
afi =c(0.000,0.000,0.000,32.110,26.310,25.640,23.200,18.730,16.300,13.830,0.000,0.000)
bfi =c(0.000,0.000,0.000,11.300,9.260,9.030,8.160,6.590,5.730,4.870,0.000,0.000)
di =c(0.000,0.000,0.000,0.330,1.000,1.000,1.000,0.320,0.000,0.000,0.000,0.000)
y = 1.0 
Kf = 300 
Qj = 1600 
Lj = 2.2 
Ej = 25 

sumT_months =  mutate( sumT_months ,  Fi = afi + bfi * y * St )

sumT_months =  mutate( sumT_months ,  Yi =  (( Fi * di ) * Kf ) / ( Qj * Lj * ( 100 - Ej )))

Yield =  sum( sumT_months $ Yi )
Yield
