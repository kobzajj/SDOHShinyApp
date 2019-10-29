#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Define UI for application that draws a histogram
shinyUI(dashboardPage(
    dashboardHeader(title="SDOH Dashboard"),
    dashboardSidebar(
        sidebarUserPanel("Jake Kobza", image='https://media.licdn.com/dms/image/C5603AQEhOVLnVqrhLg/profile-displayphoto-shrink_200_200/0?e=1577923200&v=beta&t=XFXo63G1NBp9MvEHV8FJfyGQ_zG2ROmk-eEAA6Rtyek'),
        sidebarMenu(
            menuItem("Map", tabName="map", icon = icon("map")),
            menuItem("Summary Dashboard", tabName="dash", icon=icon("address-card")),
            menuItem("Metric Comparison", tabName="metrics", icon=icon("chart-line")),
            menuItem("Data", tabName="data", icon=icon("database")))
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName="map", 
                    fluidRow(box(selectizeInput("cat_selected",
                                                "Select Category",
                                                choices=cat_choice_map,
                                                selected=cat_choice_map[1])),
                             box(selectizeInput("subcat_selected",
                                                "Select Sub-Category",
                                                choices=subcat_choice_map,
                                                selected=subcat_choice_map[1])),
                             box(selectizeInput("metric_selected",
                                                "Select Metric",
                                                choices=metric_choice_map,
                                                selected=metric_choice_map[1])),
                             box(selectizeInput("detail_selected",
                                                "State vs. County Level",
                                                choices=detail_choice_map,
                                                selected=detail_choice_map[1]))),
                    fluidRow(infoBoxOutput("maxBox"),
                             infoBoxOutput("minBox"),
                             infoBoxOutput("avgBox")),
                    fluidRow(box(leafletOutput("map"), width=600)),
                    fluidRow(box(htmlOutput("hist"), width=600))),
            tabItem(tabName="dash", "to be replaced"),
            tabItem(tabName="metrics",
                    fluidRow(box(h4("First Variable (x axis)")),
                             box(h4("Second variable (y axis)"))),
                    fluidRow(box(selectizeInput("cat_x",
                                                "Select Category",
                                                choices=cat_choice_x,
                                                selected=cat_choice_x[1])),
                             box(selectizeInput("cat_y",
                                                "Select Category",
                                                choices=cat_choice_y,
                                                selected=cat_choice_y[2]))),
                    fluidRow(box(selectizeInput("subcat_x",
                                                "Select Sub-Category",
                                                choices=subcat_choice_x,
                                                selected=subcat_choice_x[1])),
                             box(selectizeInput("subcat_y",
                                                "Select Sub-Category",
                                                choices=subcat_choice_y,
                                                selected=subcat_choice_y[7]))),
                    fluidRow(box(selectizeInput("metric_x",
                                                "Select Metric",
                                                choices=metric_choice_x,
                                                selected=metric_choice_x[1])),
                             box(selectizeInput("metric_y",
                                                "Select Metric",
                                                choices=metric_choice_y,
                                                selected=metric_choice_y[16]))),
                    fluidRow(box(htmlOutput("scatter"), width=600))),
            tabItem(tabName="data",
                    fluidRow(box(selectizeInput("table_detail",
                                                "State vs. County Level Table",
                                                choices = detail_choice_table,
                                                selected = detail_choice_table[1]))),
                    fluidRow(box(DT::dataTableOutput("table")))))
    )
))
