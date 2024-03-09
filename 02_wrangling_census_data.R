## Tidycensus functions ----
# The basics to wrangle data

# *filter() gets rid of rows
# *mutate() adds columns to the dataframe
# *group_by() and summarize() will aggregate the data by groups
# *arrange() will sort the data
# *select() will help narrow down columns
# Daisy chain all these functions together with |>


library(tidycensus)

View(vars)

## Download race Census data ----

county_diversity <- get_acs(geography = "county",
                            variables = c("B03002_001", # total
                                          "B03002_003", # white alone
                                          "B03002_004", # black alone
                                          "B03002_005", # native american
                                          "B03002_006", # asian alone
                                          "B03002_007", # pi alone
                                          "B03002_012" # hispanic or latino
                            ),
                            survey="acs5",
                            year=2022)

county_diversity

## Add a total population column ----

county_diversity <- get_acs(geography = "county",
                            variables = c("B03002_003", # white alone
                                          "B03002_004", # black alone
                                          "B03002_005", # native american
                                          "B03002_006", # asian alone
                                          "B03002_007", # pi alone
                                          "B03002_012" # hispanic or latino
                            ),
                            summary_var = "B03002_001", # total population
                            survey="acs5",
                            year=2022)

county_diversity

## Add a percent column ----

library(dplyr)

county_diversity <- county_diversity |>
  mutate(percent=estimate/summary_est*100)

## Add better variable names ----

county_diversity_race <- county_diversity |>
  mutate(race=case_when(
    variable=="B03002_003" ~"White",
    variable=="B03002_004" ~"Black",
    variable=="B03002_005" ~"Native American",
    variable=="B03002_006" ~"Asian",
    variable=="B03002_007" ~"Pacific Islander",
    variable=="B03002_012" ~"Hispanic",
    .default = "Other"
  ))

county_diversity_race

## Group up some smaller groups code ----

county_diversity_percent <- county_diversity |>
  mutate(race=case_when(
    variable=="B03002_003" ~"White",
    variable=="B03002_004" ~"Black",
    variable=="B03002_005" ~"Native American",
    variable=="B03002_006" ~"Asian Pacific Islander",
    variable=="B03002_007" ~"Asian Pacific Islander",
    variable=="B03002_012" ~"Hispanic",
    .default = "Other"
  )) |>
  group_by(GEOID, NAME, race) |>
  summarize(estimate=sum(estimate, na.rm=T),
            summary_est=mean(summary_est, na.rm=T)) |>
  mutate(percent=estimate/summary_est*100)

county_diversity_percent

## Sort the data frame low to high ----

county_diversity_percent |>
  group_by(NAME) |>
  arrange(percent)

## Sort the data frame high to low ----

county_diversity_percent_sorted <- county_diversity_percent |>
  group_by(NAME) |>
  arrange(NAME, desc(percent))

county_diversity_percent_sorted

## Narrow down the rows ----

county_diversity_percent_plurality <-
  county_diversity_percent |>
  group_by(NAME) |>
  arrange(NAME, desc(percent)) |>
  filter(row_number()==1)

county_diversity_percent_plurality

## Narrow down the rows II

county_diversity_percent_plurality <-
  county_diversity_percent |>
  group_by(NAME) |>
  arrange(NAME, desc(percent)) |>
  slice(1)

## Case study: Evictions in San Diego ----

sd_evictions <- read_csv("san_diego_evictions.csv")

sd_evictions

## Go back and modify your code ----

sd_tract_diversity <- get_acs(geography = "_____",
                              state = "__",
                              county = "__________",
                              variables = c("B03002_003", # white alone
                                            "B03002_004", # black alone
                                            "B03002_005", # native american
                                            "B03002_006", # asian alone
                                            "B03002_007", # pi alone
                                            "B03002_012" # hispanic or latino
                              ),
                              summary_var = "B03002_001", # total population
                              survey="acs5",
                              year=2022)

## Wrangle the census tract data ----

sd_tract_diversity_plurality <- sd_tract_diversity |>
  mutate(race=case_when(
    variable=="B03002_003" ~"White",
    variable=="B03002_004" ~"Black",
    variable=="B03002_005" ~"Native American",
    variable=="B03002_006" ~"Asian Pacific Islander",
    variable=="B03002_007" ~"Asian Pacific Islander",
    variable=="B03002_012" ~"Hispanic",
    .default = "Other"
  )) |>
  group_by(GEOID, NAME, race) |>
  summarize(estimate=sum(estimate, na.rm=T),
            summary_est=mean(summary_est, na.rm=T)) |>
  mutate(percent=estimate/summary_est*100) |>
  group_by(GEOID, NAME) |>
  arrange(GEOID, NAME, desc(percent)) |>
  slice(1)

sd_tract_diversity_plurality


## Join data ----

sd_joined <- inner_join(sd_tract_diversity_plurality, sd_evictions)

sd_joined

## Summarize the evictions data ----

sd_joined |>
  group_by(race) |>
  summarize(population=sum(summary_est, na.rm=T),
            total_evictions=sum(total_evictions, na.rm=T)) |>
  mutate(rate_of_evictions=total_evictions/population*1000) |>
  arrange(desc(rate_of_evictions))
