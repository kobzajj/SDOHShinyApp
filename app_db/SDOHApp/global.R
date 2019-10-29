library(shiny)
library(leaflet)
library(shinydashboard)
library(DT)
library(raster)
library(googleVis)
library(openintro)

counties_df <- read.csv('data/sdoh_counties.csv')
states_df <- read.csv('data/sdoh_states.csv')
metrics_df <- read.csv('data/metric_table.csv')

cat_choice_map <- unique(metrics_df$category)
subcat_choice_map <- unique(metrics_df$subcategory)
metric_choice_map <- unique(metrics_df$metric.name)
detail_choice_map <- c("State", "County")

cat_choice_x <- unique(metrics_df$category)
subcat_choice_x <- unique(metrics_df$subcategory)
metric_choice_x <- unique(metrics_df$metric.name)
cat_choice_y <- unique(metrics_df$category)
subcat_choice_y <- unique(metrics_df$subcategory)
metric_choice_y <- unique(metrics_df$metric.name)

detail_choice_table <- c("State", "County")

USA_county <- getData("GADM", country="usa", level=2)
USA_state <- getData("GADM", country="usa", level=1)

sdoh_df_metric_state <- na.omit(states_df[, c("state", "unemployment")])
sdoh_df_metric_state$state <- abbr2state(as.character(sdoh_df_metric_state$state))
sdoh_df_metric_state <- na.omit(sdoh_df_metric_state)
temp <- merge(USA_state, sdoh_df_metric_state, by.x="NAME_1", by.y="state", all.x=TRUE)
mypal <- colorNumeric(palette="viridis", domain=temp[["unemployment"]], na.color="grey")
