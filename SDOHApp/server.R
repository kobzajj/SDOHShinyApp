#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

shinyServer(function(input, output, session) {
    
    observeEvent(input$cat_selected, {
        subcat_choice <- unique(metrics_df[metrics_df$category == input$cat_selected, 'subcategory'])
        updateSelectizeInput(
            session, "subcat_selected",
            choices = subcat_choice,
            selected = subcat_choice[1]
        )
        metric_choice <- unique(metrics_df[metrics_df$category == input$cat_selected & metrics_df$subcategory == input$subcat_selected, 'metric.name'])
        updateSelectizeInput(
            session, "metric_selected",
            choices = metric_choice,
            selected = metric_choice[1]
        )
    })
    
    observeEvent(input$subcat_selected, {
        metric_choice <- unique(metrics_df[metrics_df$category == input$cat_selected & metrics_df$subcategory == input$subcat_selected, 'metric.name'])
        updateSelectizeInput(
            session, "metric_selected",
            choices = metric_choice,
            selected = metric_choice[1]
        )
    })
    
    observeEvent(input$metric_selected, {

        metric_selected_new <- as.character(metrics_df[metrics_df$metric.name == input$metric_selected, "metric.id"])

        proxy <- leafletProxy("map")

        if (input$detail_selected == "State") {
            sdoh_df_metric_state <- na.omit(states_df[, c("state", metric_selected_new)] %>%
                                                mutate(., state=abbr2state(as.character(state))))
            temp <- merge(USA_state, sdoh_df_metric_state, by.x="NAME_1", by.y="state", all.x=TRUE)
            mypal <- colorNumeric(palette="viridis", domain=temp[[metric_selected_new]], na.color="grey")

            proxy %>%
                addPolygons(data=USA_state, stroke=FALSE, smoothFactor=0.2, fillOpacity=0.4,
                            fillColor= ~mypal(temp[[metric_selected_new]]),
                            popup = paste("State: ", temp$NAME_1, "<br>", "County: ", "<br>", "Unemployment: ", temp[[metric_selected_new]], "<br>")) %>%
                addLegend(position="bottomleft", pal=mypal, values=temp[[metric_selected_new]], title="Unemployment", opacity=1)
        } else {
            sdoh_df_metric_county <- na.omit(counties_df[, c("state", "county", metric_selected_new)] %>%
                                                 mutate(., state=abbr2state(state)))
            temp <- merge(USA_county, sdoh_df_metric_county,
                          by.x=c("NAME_1", "NAME_2"), by.y=c("state", "county"), all.x=TRUE)
            mypal <- colorNumeric(palette="viridis", domain=temp[[metric_selected_new]], na.color="grey")

            proxy %>%
                addPolygons(data=USA_county, stroke=FALSE, smoothFactor=0.2, fillOpacity=0.4,
                            fillColor= ~mypal(temp[[metric_selected_new]]),
                            popup = paste("State: ", temp$NAME_1, "<br>", "County: ", temp$NAME_2, "<br>", "Unemployment: ", temp[[metric_selected_new]], "<br>")) %>%
                addLegend(position="bottomleft", pal=mypal, values=temp[[metric_selected_new]], title="Unemployment", opacity=1)
        }
    })
    
    # metric_selected_update <- reactive({
    #     as.character(metrics_df[metrics_df$metric.name == input$metric_selected, "metric.id"])
    # })

    output$map <- renderLeaflet({
        # metric_selected_new <- metric_selected_update()
        leaflet() %>%
                addProviderTiles("OpenStreetMap.Mapnik")
    })

})
