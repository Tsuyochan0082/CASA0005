# Ineqaulity task - week 4

## Load packages
library(tidyverse)
library(sf)
library(here)
library(janitor)
library(countrycode)

## read in data

```{r}
HDI <- read_csv(here::here("data", "gender_inequality_difference2010_19.csv"),
                locale = locale(encoding = "latin1"),
                na = " ", skip=0)

World <- st_read("data/World_Countries_(Generalized)_9029012925078512962.geojson")

## Column names

HDIcols<- HDI %>%
  clean_names()%>%
  select(country, gii_2019, gii_2010, difference)%>%
  mutate(iso_code=countrycode(country, origin = 'country.name', destination = 'iso2c'))

## Join

#Join the csv to world shape file

Join_HDI <- World %>% 
  clean_names() %>%
  left_join(., 
            HDIcols,
            # change to "aff_iso" = "iso_code"
            by = c("iso" = "iso_code"))

#Remove the one with no difference
Join_HDI_filtered <- Join_HDI %>%
  filter(!is.na(gii_2010))

#mapping
ggplot(data = Join_HDI_filtered) +
  # メインの地図レイヤー
  geom_sf(aes(fill = difference), 
          color = "white",  # 国境線を白で描く
          size = 0.1) +     # 国境線を細くする
  
  # 色のスケールを調整するレイヤー
  scale_fill_gradient2(low = "blue",      # 値が小さい（改善）と青色
                       mid = "white",     # 0（変化なし）は白
                       high = "red",      # 値が大きい（悪化）と赤色
                       midpoint = 0,      # 色の中心を0に設定
                       na.value = "grey80") + # データがない国は灰色に
  
  # 背景などを消して、地図をスッキリさせるテーマ
  theme_void()
