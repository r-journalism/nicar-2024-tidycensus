## Downloading "Spatial" ACS data ----

library(tidyverse)
library(tidycensus)
library(sf)
library(mapview)

median_value_map <- get_acs(
  geography = "tract",
  state= "MD",
  county="Baltimore City",
  variables = "B25077_001", # median values of home
  year = 2022,
  geometry = TRUE
)

median_value_map

## Exploring Census data interactively ----

library(mapview)

mapview(median_value_map)

## Creating a shaded map with `zcol` ----

median_value_map <- get_acs(
  geography = "tract",
  state= "MD", # Changeme
  county="Baltimore County", # Change me
  variables = "B25077_001", # median values of home
  year = 2022,
  geometry = TRUE
)

mapview(median_value_map, zcol = "estimate")

## Try all the code again in a different county ----

median_value_map <- get_acs(
  geography = "tract",
  state= "MD", # Changeme
  county="Baltimore County", # Change me
  variables = "B25077_001", # median values of home
  year = 2022,
  geometry = TRUE
)

mapview(median_value_map, zcol = "estimate")

## Migration data ----

county_migration <- get_flows(
  geography = "county",
  county = "Baltimore City",
  state = "MD"
)

county_migration

## Downloading map data ----

county_map <- get_acs(
  geography = "county",
  variable = c("Population"="B03002_001"),
  geometry = TRUE
)

county_map

## Prep the migration data ----


county_migration_moved <- county_migration |>
  filter(variable=="MOVEDIN") |>
  filter(!is.na(GEOID2)) |>
  select(GEOID=GEOID2, migration=estimate)

county_map_migration <- county_map %>%
  inner_join(county_migration_moved)

mapview(county_map_migration, zcol = "migration")


## Can you map migration out? ----


county_migration_moved <- county_migration |>
  filter(variable=="????????") |>
  filter(!is.na(GEOID2)) |>
  select(GEOID=GEOID2, migration=estimate)
