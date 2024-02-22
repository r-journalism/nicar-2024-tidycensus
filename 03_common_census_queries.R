library(tidycensus)
library(tidyverse)

## Example of iterating with loops ----
for (i in 1:10) {
  print(i)
}

## Multiple years of Census data ----

big_census_data <- tibble() # creates a blank data frame

for (i in 2020:2022) {
  median_df <- get_acs( # temporary dataframe
    geography = "county",
    variables = "B25077_001", # median home values
    year = i
  ) |>
    mutate(year = i) # so we can identify which year

  big_census_data <- bind_rows(big_census_data, median_df) |>
    arrange(GEOID, year)
  # appends the temporary dataframe to the permanent one
}

big_census_data

## Quickly calculate percent change ----

library(tidyr)

home_value_change <- big_census_data |>
  ungroup() |>
  filter(year!=2021) |>
  select(NAME, estimate, year) |>
  pivot_wider(names_from="year", values_from="estimate") |>
  mutate(change=round((`2022`-`2020`)/`2020`*100,2)) |>
  arrange(desc(change))

View(home_value_change)

### Looping through states to get tracts

state_names <- c("DC", "MD", "VA") # Get a list of state names or abbreviations

tract_data <- tibble()
for (i in 1:length(state_names)) {
  tract_df <- get_acs(
    geography = "tract",
    variables = "B25077_001",
    year = 2022,
    state=state_names[i] # Swap out the state name in the array
  )

  tract_data <- bind_rows(tract_data, tract_df)
}

tract_data

## Get a list of state names and/or abbreviations ----

state_names <- c(state.name, "District of Columbia")
state_abbs <- c(state.abb, "DC")

state_df <- data.frame(state_names, state_abbs)
state_df

## Diversity score by county ----



# pulls data from 2022 by county

set_year <- 2022
county_diversity <- get_acs(geography = "county",
                            variables = c("B03002_003", # white alone
                                          "B03002_004", # black alone
                                          "B03002_005", # native american
                                          "B03002_006", # asian alone
                                          "B03002_007", # pi alone
                                          "B03002_012", # hispanic or latino
                                          "B03002_002" # not hispanic
                            ),
                            summary_var = "B03002_001", # total population
                            survey="acs5",
                            year=set_year) %>%
  mutate(race=case_when(
    variable=="B03002_003" ~"White",
    variable=="B03002_004" ~"Black",
    variable=="B03002_005" ~"Native American",
    variable=="B03002_006" ~"Asian PI",
    variable=="B03002_007" ~"Asian PI",
    variable=="B03002_012" ~"Hispanic",
    variable=="B03002_002" ~"Not Hispanic",
    TRUE ~ "Other"
  )) %>%
  group_by(GEOID, NAME, race) %>%
  summarize(estimate=sum(estimate, na.rm=T),
            summary_est=mean(summary_est, na.rm=T)) %>%
  mutate(pct = estimate/summary_est) %>%
  select(GEOID, race, pct) %>%
  pivot_wider(names_from="race", values_from="pct") %>%
  mutate(diversity_index= 1 - ((White^2 + Black^2 + `Native American`^2 + `Asian PI`^2))) %>%
  # this is the old way that takes into account hispanic/non-hispanic
  #((White^2 + Black^2 + `Native American`^2 + `Asian PI`^2) * (Hispanic^2 + `Not Hispanic`^2))) %>%
  select(geoid=GEOID, white_percent=White, diversity_index) %>%
  mutate(year=set_year)

glimpse(county_diversity)

# Exporting
write_csv(county_diversity, paste0("county_diversity_", set_year, ".csv", na=""))

### poverty quantile ----
set_year <- 2022
poverty_df <- get_acs(geography = "county",
                      variables = "B17001_002", #Estimate!!Poverty
                      summary_var = "B17001_001", #Estimate!!Total_Population
                      survey="acs5",
                      year=set_year) %>%
  mutate(pctpov = 100 * (estimate/summary_est)) %>%
  mutate(quantile=ntile(pctpov, 4))

View(poverty_df)

# Exporting
write_csv(poverty_df, paste0("poverty_df_", set_year, ".csv", na=""))


## age groups ----

set_year <- 2022
state_ages <- get_acs(
  geography = "state",
  table = "B01001",
  year = set_year
)

## reclassify and group the variables however you like
state_ages <- state_ages %>%
  mutate(var=case_when(
    # original variable names below
    # variable=="B01001_001" ~ "Total population",
    # variable=="B01001_002" ~ "Male",
    # variable=="B01001_003" ~ "Male - Under 5",
    # variable=="B01001_004" ~ "Male - 5 to 9",
    # variable=="B01001_005" ~ "Male - 10 to 14",
    # variable=="B01001_006" ~ "Male - 15 to 17",
    # variable=="B01001_007" ~ "Male - 18 to 19",
    # variable=="B01001_008" ~ "Male - 20",
    # variable=="B01001_009" ~ "Male - 21",
    # variable=="B01001_010" ~ "Male - 22 to 24",
    # variable=="B01001_011" ~ "Male - 25 to 29",
    # variable=="B01001_012" ~ "Male - 30 to 34",
    # variable=="B01001_013" ~ "Male - 35 to 39",
    # variable=="B01001_014" ~ "Male - 40 to 44",
    # variable=="B01001_015" ~ "Male - 45 to 49",
    # variable=="B01001_016" ~ "Male - 50 to 54",
    # variable=="B01001_017" ~ "Male - 55 to 59",
    # variable=="B01001_018" ~ "Male - 60 to 61",
    # variable=="B01001_019" ~ "Male - 62 to 64",
    # variable=="B01001_020" ~ "Male - 65 to 66",
    # variable=="B01001_021" ~ "Male - 67 to 69",
    # variable=="B01001_022" ~ "Male - 70 to 74",
    # variable=="B01001_023" ~ "Male - 75 to 79",
    # variable=="B01001_024" ~ "Male - 80 to 84",
    # variable=="B01001_025" ~ "Male - 85+",
    # variable=="B01001_026" ~ "Female",
    # variable=="B01001_027" ~ "Female - Under 5",
    # variable=="B01001_028" ~ "Female - 5 to 9",
    # variable=="B01001_029" ~ "Female - 10 to 14",
    # variable=="B01001_030" ~ "Female - 15 to 17",
    # variable=="B01001_031" ~ "Female - 18 to 19",
    # variable=="B01001_032" ~ "Female - 20",
    # variable=="B01001_033" ~ "Female - 21",
    # variable=="B01001_034" ~ "Female - 22 to 24",
    # variable=="B01001_035" ~ "Female - 25 to 29",
    # variable=="B01001_036" ~ "Female - 30 to 34",
    # variable=="B01001_037" ~ "Female - 35 to 39",
    # variable=="B01001_038" ~ "Female - 40 to 44",
    # variable=="B01001_039" ~ "Female - 45 to 49",
    # variable=="B01001_040" ~ "Female - 50 to 54",
    # variable=="B01001_041" ~ "Female - 55 to 59",
    # variable=="B01001_042" ~ "Female - 60 to 61",
    # variable=="B01001_043" ~ "Female - 62 to 64",
    # variable=="B01001_044" ~ "Female - 65 to 66",
    # variable=="B01001_045" ~ "Female - 67 to 69",
    # variable=="B01001_046" ~ "Female - 70 to 74",
    # variable=="B01001_047" ~ "Female - 75 to 79",
    # variable=="B01001_048" ~ "Female - 80 to 84",
    # variable=="B01001_049" ~ "Female - 85+"
    # combined age groups below
    variable=="B01001_001" ~ "Total population",
    variable=="B01001_002" ~ "Male",
    variable=="B01001_003" ~ "Male - Under 65",
    variable=="B01001_004" ~ "Male - Under 65",
    variable=="B01001_005" ~ "Male - Under 65",
    variable=="B01001_006" ~ "Male - Under 65",
    variable=="B01001_007" ~ "Male - Under 65",
    variable=="B01001_008" ~ "Male - Under 65",
    variable=="B01001_009" ~ "Male - Under 65",
    variable=="B01001_010" ~ "Male - Under 65",
    variable=="B01001_011" ~ "Male - Under 65",
    variable=="B01001_012" ~ "Male - Under 65",
    variable=="B01001_013" ~ "Male - Under 65",
    variable=="B01001_014" ~ "Male - Under 65",
    variable=="B01001_015" ~ "Male - Under 65",
    variable=="B01001_016" ~ "Male - Under 65",
    variable=="B01001_017" ~ "Male - Under 65",
    variable=="B01001_018" ~ "Male - Under 65",
    variable=="B01001_019" ~ "Male - Under 65",
    variable=="B01001_020" ~ "Male - 65 to 80",
    variable=="B01001_021" ~ "Male - 65 to 80",
    variable=="B01001_022" ~ "Male - 65 to 80",
    variable=="B01001_023" ~ "Male - 65 to 80",
    variable=="B01001_024" ~ "Male - 80+",
    variable=="B01001_025" ~ "Male - 80+",
    variable=="B01001_026" ~ "Female",
    variable=="B01001_027" ~ "Female - Under 65",
    variable=="B01001_028" ~ "Female - Under 65",
    variable=="B01001_029" ~ "Female - Under 65",
    variable=="B01001_030" ~ "Female - Under 65",
    variable=="B01001_031" ~ "Female - Under 65",
    variable=="B01001_032" ~ "Female - Under 65",
    variable=="B01001_033" ~ "Female - Under 65",
    variable=="B01001_034" ~ "Female - Under 65",
    variable=="B01001_035" ~ "Female - Under 65",
    variable=="B01001_036" ~ "Female - Under 65",
    variable=="B01001_037" ~ "Female - Under 65",
    variable=="B01001_038" ~ "Female - Under 65",
    variable=="B01001_039" ~ "Female - Under 65",
    variable=="B01001_040" ~ "Female - Under 65",
    variable=="B01001_041" ~ "Female - Under 65",
    variable=="B01001_042" ~ "Female - Under 65",
    variable=="B01001_043" ~ "Female - Under 65",
    variable=="B01001_044" ~ "Female - 65 to 80",
    variable=="B01001_045" ~ "Female - 65 to 80",
    variable=="B01001_046" ~ "Female - 65 to 80",
    variable=="B01001_047" ~ "Female - 65 to 80",
    variable=="B01001_048" ~ "Female - 80+",
    variable=="B01001_049" ~ "Female - 80+"
  )) %>%
  mutate(year=set_year)

# resummarizing based on consolidated age groups and gender
sa <-state_ages %>%
  group_by(NAME, var, year) %>%
  summarize(population=sum(estimate, na.rm=T))

# creating a second data frame based on consolidated age groups (and not gender)
sa_groups <- state_ages %>%
  filter(grepl("\\-", var)) %>%
  mutate(var = gsub(".*- ", "", var)) %>%
  group_by(NAME, var, year) %>%
  summarize(population=sum(estimate, na.rm=T))

# combining these two summarized data frames together
sa_combined <- bind_rows(sa, sa_groups) %>%
  mutate(sex=gsub(" -.*", "", var)) %>%
  mutate(sex=case_when(
    sex=="Female" ~ "Female",
    sex=="Male" ~ "Male",
    TRUE ~ "All"
  )) %>%
  mutate(age_group=gsub(".* - ", "", var)) %>%
  mutate(age_group=gsub("Female", "All", age_group),
         age_group=gsub("Male", "All", age_group),
         age_group=gsub("Total population", "All", age_group)) %>%
  dplyr::select(-var)


## Exporting as a CSV
write_csv(sa_combined, paste0("age_groups_", set_year, ".csv", na=""))
