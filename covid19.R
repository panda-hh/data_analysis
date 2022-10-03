install.packages('COVID19')
install.packages('dplyr')
install.packages('tidyr')
install.packages('ggplot2')

library(COVID19)
library(dplyr)
library(tidyr)
library(ggplot2)

data = COVID19::covid19()

# 1.다음의 열에 해당하는 데이터만 선택해 data_select 변수를 만든다.
#(dplyr 패키지의 select 함수 사용)
#date, confirmed, deaths, recovered, tests, people_vaccinated, people_fully_vaccinated, vent, population, key_apple_mobility, key_gadm

data_select=
  data %>%
  select('date', 'confirmed', 'deaths', 'recovered', 'tests', 'people_vaccinated', 'people_fully_vaccinated', 'vent', 'population', 'key_apple_mobility', 'key_gadm') %>%
  head(730)

data_select

#2.국가명이 마카오(Macao)인 데이터만 선택
#힌트
# - filter 함수 사용
# - 국가명 열은 key_apple_mobility 

#num2 =
data_select %>%
  filter(key_apple_mobility == 'Macao')

#3.위 결과에서 살펴보듯이 감염자, 사망자, 접종인구 등 데이터가 NA로 빈 곳이 많다. 코로나가 처음 시작되었을 때는 당연히 해당 데이터가 없겠지만, 백신 인구수 데이터가 있다가 NA가 나온 후 다시 데이터가 나온다는 것은 간혹 데이터가 누락된다는 뜻이다. 
#따라서 이러한 것들은 연속성을 위해 보정해줄 필요가 있다. 또한 국가가 NA인 데이터는 분석을 할 수 없으므로 제외하는 것이 좋다.
#클렌징 처리를 위해 국가명이 없는 데이터는 삭제하며, 각 국가별로 [confirmed, deaths, recovered, tests, people_vaccinated, people_fully_vaccinated, vent, population] 열은 NA일 경우 전일 데이터로 보정하라.

data_select= data_select %>% #3번 이후 data
  filter(!is.na(key_apple_mobility)) %>%
  group_by(key_apple_mobility) %>%
  arrange(key_apple_mobility, date) %>%
  fill(confirmed, deaths, recovered, tests, people_vaccinated, people_fully_vaccinated, vent, population)

# 4.인구 대비 감염률, 인구 대비 사망률, 인구 대비 고위험률, 인구 대비 접종률을 계산한다. 
# 접종률의 경우 단순 접종자수에서 접종 완료수를 빼 
# [인구 대비 접종 미완료 비율]과 [인구 대비 접종 완료] 비율을 각각 계산한다.

# confirm_ratio = confirmed/population #인구 대비 감염률
# death_ratio = deaths/population #인구 대비 사망률
# vent_ratio = vent/population #인구 대비 고위험률
# vacc_fully_ratio = people_fully_vaccinated/population
# vacc_not_fully_ratio = (people_vaccinated-people_fully_vaccinated)/population

data_select = data_select %>%
  mutate(confirm_ratio = confirmed/population) %>%
  mutate(death_ratio = deaths/population) %>%
  mutate(vent_ratio = vent/population) %>%
  mutate(vacc_fully_ratio = people_fully_vaccinated/population) %>%
  mutate(vacc_not_fully_ratio = (people_vaccinated-people_fully_vaccinated)/population)
  
#5.2022년 4월 10일 기준 국가별 감염률, 사망률을 선택해 감염률을 기준으로 정렬한다.

data_select %>%
  filter(date == '2022-04-10') %>%
  select(key_apple_mobility, confirm_ratio, death_ratio) %>%
  arrange(desc(confirm_ratio)) %>%
  print(n=100)

#6.접종완료율이 증가하면 사망률이 감소하는지 확인하고자 한다. 2022년 4월 10일 기준 x축은 인구대비 접종완료비율, y축은 인구대비 사망률을 점도표로 나타내라. 
# 또한 각 국가별로 색을 다르게 하고, 텍스트를 나타내라. 마지막으로 범례는 필요 없으므로 삭제한다.
data_select %>%
  filter(date == '2022-04-10') %>%
  ggplot(aes(x = vacc_fully_ratio, y = death_ratio)) +
  theme(legend.position = "none") +
  geom_point(aes(color=key_apple_mobility), size=10) +
  geom_smooth(method='lm', se=FALSE) +
  geom_text(aes(label=key_apple_mobility), size=3)


#7.신흥국과 선진국에 따른 사망률/백신접종률 차이를 보고자 한다. 먼저 국가명이 아래 내에 존재하면 ‘신흥국’ 그렇지 않으면 ‘선진국’으로 구분하여 변수에 저장하라. 그 후 2022년 4월 10일 기준 신흥국과 선진국에 따른 사망률/백신접종률 차이를 보라.

data_select %>%
  filter(date == '2022-04-10') %>%
  mutate(country = if_else(key_apple_mobility %in% c('Albania', 'Argentina', 'Brazil', 'Bulgaria', 'Cambodia', 'Chile', 'Colombia', 'Egypt',  'Estonia', 'Georgia', 'Greece', 'India', 'Indonesia', 'Latvia', 'Lithuania', 'Malaysia',  'Mexico', 'Philippines', 'Puerto Rico', 'Romania', 'Serbia', 'Slovakia', 'Slovenia', 'South Africa', 'Thailand', 'Turkey', 'Ukraine', 'Uruguay', 'Vietnam'),
                           '신흥국', '선진국')) %>%
  ggplot(aes(x = vacc_fully_ratio, y = death_ratio)) +
  geom_point(aes(color=country), size=10) +
  geom_text(aes(label=key_apple_mobility), size=3)


#8. 신흥국/선진국 별 접종 완료 비율을 그려라.

data_select %>%
  mutate(country = if_else(key_apple_mobility %in% c('Albania', 'Argentina', 'Brazil', 'Bulgaria', 'Cambodia', 'Chile', 'Colombia', 'Egypt',  'Estonia', 'Georgia', 'Greece', 'India', 'Indonesia', 'Latvia', 'Lithuania', 'Malaysia',  'Mexico', 'Philippines', 'Puerto Rico', 'Romania', 'Serbia', 'Slovakia', 'Slovenia', 'South Africa', 'Thailand', 'Turkey', 'Ukraine', 'Uruguay', 'Vietnam'),
                           '신흥국', '선진국')) %>%
  ggplot(aes(x = date, y = vacc_fully_ratio, group=key_apple_mobility)) +
  geom_line(aes(color=country))

#9. 시계열에 따른 사망률을 보고자 하며, 한국만 색깔과 모양을 다르게 하여 한눈에 보고자 한다. 

data_select %>%
  mutate(country = if_else(key_apple_mobility %in% c('Republic of Korea'),
                           'Korea', 'Other')) %>%
  ggplot(aes(x = date, y = death_ratio, group=key_apple_mobility)) +
  geom_line(aes(color=country)) +
  geom_text(
    data = data_select %>%  group_by(key_apple_mobility) %>%  filter(date == last(date)), aes(label = key_apple_mobility, x = date + 0.5, y = death_ratio), size = 2)

