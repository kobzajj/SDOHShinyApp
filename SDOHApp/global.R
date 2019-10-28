library(shiny)
library(leaflet)
library(shinydashboard)
library(DT)
library(raster)

counties_df <- read.csv('../data/sdoh_counties.csv')
states_df <- read.csv('../data/sdoh_states.csv')
metrics_df <- read.csv('../data/metric_table.csv')

cat_choice <- unique(metrics_df$category)
subcat_choice <- unique(metrics_df$subcategory)
metric_choice <- unique(metrics_df$metric.name)
detail_choice <- c("State", "County")

USA_county <- getData("GADM", country="usa", level=2)
USA_state <- getData("GADM", country="usa", level=1)