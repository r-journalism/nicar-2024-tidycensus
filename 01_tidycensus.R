### Getting started with the tidycensus ----

# delete the hashes to run the code if you have not run this line of code before
# install.packages(c("tidycensus", "tidyverse", "sf", "mapview", "usethis"))

# Every time you start up this RStudio project, you have to reload the libraries that have the functions you want to run

library(tidyverse)
library(tidycensus)
library(mapview)
library(sf)

## Optional: your Census API key ----

# https://api.census.gov/data/key_signup.html

# tidycensus (and the Census API) can be used without an API key, but you will be limited to 500 queries per day

census_api_key("YOUR KEY GOES HERE", install = TRUE)

## Using the `get_acs()` function ----

# The `get_acs()` function is your portal to access ACS data using tidycensus

# The two required arguments are `geography` and `variables`.  The function defaults to the 2017-2021 5-year ACS
library(tidycensus)

median_income <- get_acs(
  geography = "county",
  variables = "B19013_001", # median income
  year = 2021
)

# click on the rectangular grid icon next to 'median_income' on the top right under the `Environment` tab
# or run this command below
View(median_income)

# ACS data are returned with five columns: `GEOID`, `NAME`, `variable`, `estimate`, and `moe`

## Exporting your data ----

library(readr)

write_csv(median_income, "whatever_filename_you_want.csv", na="")

## 1-year ACS data ----

# 1-year ACS data are more current, but are only available for geographies of population 65,000 and greater

# Access 1-year ACS data with the argument `survey = "acs1"`; defaults to `"acs5"`

median_value_1yr <- get_acs(
  geography = "county",
  variables = "B25077_001", # median value of homes
  year = 2021,
  survey = "acs1" # <<
)


# click on the rectangular grid icon next to 'median_income_1yr on the top right under the `Environment` tab
# or run this command below
View(median_income_1yr)


## Requesting tables of variables ----

# The `table` parameter can be used to obtain all related variables in a "table" at once

income_table <- get_acs(
  geography = "county",
  table = "B19001", #<<
  year = 2021
)

View(income_table)

## Querying tract data requires county and state ----

# For geographies available below the state level, the `state` parameter allows you to query data for a specific state
# For smaller geographies (Census tracts, block groups), a `county` can also be requested
# __tidycensus__ translates state names and postal abbreviations internally, so you don't need to remember the FIPS codes!
# Example: data on median household income in Minnesota by county

sd_value <- get_acs(
  geography = "tract",
  variables = "B25077_001",
  state = "CA",
  county = "San Diego",
  year = 2022
)

View(sd_value)

## Searching for variables ----

# To search for variables, use the `load_variables()` function along with a year and dataset
# The `View()` function in RStudio allows for interactive browsing and filtering

vars <- load_variables(2022, "acs5")

View(vars)

## "Tidy" or long-form data ----

age_sex_table <- get_acs(
  geography = "state",
  table = "B01001",
  year = 2022,
  survey = "acs1",
)

age_sex_table

## "Wide" data ----

age_sex_table_wide <- get_acs(
  geography = "state",
  table = "B01001",
  year = 2022,
  survey = "acs1",
  output = "wide"
)

age_sex_table_wide

## Renaming variables easily ----

ca_education <- get_acs(
  geography = "county",
  state = "CA",
  variables = c(percent_high_school = "DP02_0062P",
                percent_bachelors = "DP02_0065P",
                percent_graduate = "DP02_0066P"),
  year = 2021
)

ca_education

## Tagalog speakers by state (1-year ACS) ----

tagalog1 <- get_acs(
  geography = "state",
  variables = "B16001_099",
  year = 2022,
  survey = "acs1"
)

tagalog1

## Tagalog speakers by state (5-year ACS) ----

tagalog5 <- get_acs(
  geography = "state",
  variables = "B16001_099",
  year = 2022,
  survey = "acs5"
)

tagalog5

## 2020 US Census in Tidycensus ----

pop20 <- get_decennial(
  geography = "state",
  variables = "P1_001N",
  year = 2020
)

pop20

