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
        subcat_choice_map <- unique(metrics_df[metrics_df$category == input$cat_selected, 'subcategory'])
        updateSelectizeInput(
            session, "subcat_selected",
            choices = subcat_choice_map,
            selected = subcat_choice_map[1]
        )
        metric_choice_map <- unique(metrics_df[metrics_df$category == input$cat_selected & metrics_df$subcategory == input$subcat_selected, 'metric.name'])
        updateSelectizeInput(
            session, "metric_selected",
            choices = metric_choice_map,
            selected = metric_choice_map[1]
        )
    })
    
    observeEvent(input$subcat_selected, {
        metric_choice_map <- unique(metrics_df[metrics_df$category == input$cat_selected & metrics_df$subcategory == input$subcat_selected, 'metric.name'])
        updateSelectizeInput(
            session, "metric_selected",
            choices = metric_choice_map,
            selected = metric_choice_map[1]
        )
    })
    
    observeEvent(input$cat_x, {
        subcat_choice_x <- unique(metrics_df[metrics_df$category == input$cat_x, 'subcategory'])
        updateSelectizeInput(
            session, "subcat_x",
            choices = subcat_choice_x,
            selected = subcat_choice_x[1]
        )
        metric_choice_x <- unique(metrics_df[metrics_df$category == input$cat_x & metrics_df$subcategory == input$subcat_x, 'metric.name'])
        updateSelectizeInput(
            session, "metric_x",
            choices = metric_choice_x,
            selected = metric_choice_x[1]
        )
    })
    
    observeEvent(input$subcat_x, {
        metric_choice_x <- unique(metrics_df[metrics_df$category == input$cat_x & metrics_df$subcategory == input$subcat_x, 'metric.name'])
        updateSelectizeInput(
            session, "metric_x",
            choices = metric_choice_x,
            selected = metric_choice_x[1]
        )
    })
    
    observeEvent(input$cat_y, {
        subcat_choice_y <- unique(metrics_df[metrics_df$category == input$cat_y, 'subcategory'])
        updateSelectizeInput(
            session, "subcat_y",
            choices = subcat_choice_y,
            selected = subcat_choice_y[1]
        )
        metric_choice_y <- unique(metrics_df[metrics_df$category == input$cat_y & metrics_df$subcategory == input$subcat_y, 'metric.name'])
        updateSelectizeInput(
            session, "metric_y",
            choices = metric_choice_y,
            selected = metric_choice_y[1]
        )
    })
    
    observeEvent(input$subcat_y, {
        metric_choice_y <- unique(metrics_df[metrics_df$category == input$cat_y & metrics_df$subcategory == input$subcat_y, 'metric.name'])
        updateSelectizeInput(
            session, "metric_y",
            choices = metric_choice_y,
            selected = metric_choice_y[1]
        )
    })
    
    observeEvent(input$metric_selected, {

        if (input$metric_selected != "") {
            metric_selected_new <- as.character(metrics_df[metrics_df$metric.name == input$metric_selected, "metric.id"])
            
            proxy <- leafletProxy("map")
            
            if (input$detail_selected == "State") {
                sdoh_df_metric_state <- na.omit(states_df[, c("state", metric_selected_new)])
                sdoh_df_metric_state$state <- abbr2state(as.character(sdoh_df_metric_state$state))
                sdoh_df_metric_state <- na.omit(sdoh_df_metric_state)
                temp <- merge(USA_state, sdoh_df_metric_state, by.x="NAME_1", by.y="state", all.x=TRUE)
                mypal <- colorNumeric(palette="viridis", domain=temp[[metric_selected_new]], na.color="grey")
                
                proxy %>% clearShapes() %>% clearControls()
                proxy %>%
                    addPolygons(data=USA_state, stroke=FALSE, smoothFactor=0.2, fillOpacity=0.4,
                                fillColor= ~mypal(temp[[metric_selected_new]]),
                                popup = paste("State: ", temp$NAME_1, "<br>", input$metric_selected, ": ", round(temp[[metric_selected_new]], 3), "<br>")) %>%
                    addLegend(position="bottomleft", pal=mypal, values=temp[[metric_selected_new]], title=input$metric_selected, opacity=1)
            } else {
                sdoh_df_metric_county <- na.omit(counties_df[, c("state", "county", metric_selected_new)])
                sdoh_df_metric_county$state <- abbr2state(as.character(sdoh_df_metric_county$state))
                sdoh_df_metric_county <- na.omit(sdoh_df_metric_county)
                temp <- merge(USA_county, sdoh_df_metric_county,
                              by.x=c("NAME_1", "NAME_2"), by.y=c("state", "county"), all.x=TRUE)
                mypal <- colorNumeric(palette="viridis", domain=temp[[metric_selected_new]], na.color="grey")
                
                proxy %>% clearShapes() %>% clearControls()
                proxy %>%
                    addPolygons(data=USA_county, stroke=FALSE, smoothFactor=0.2, fillOpacity=0.4,
                                fillColor= ~mypal(temp[[metric_selected_new]]),
                                popup = paste("State: ", temp$NAME_1, "<br>", "County: ", temp$NAME_2, "<br>", input$metric_selected, ": ", round(temp[[metric_selected_new]], 3), "<br>")) %>%
                    addLegend(position="bottomleft", pal=mypal, values=temp[[metric_selected_new]], title=input$metric_selected, opacity=1)
            }
        }
    })
    
    scatter_data <- reactive({
        na.omit(counties_df[, c(as.character(metrics_df[metrics_df$metric.name == input$metric_x, "metric.id"]), 
                                as.character(metrics_df[metrics_df$metric.name == input$metric_y, "metric.id"]))])
    })
    
    # scatter_options <- reactive({
    #     list(width="600px", height="300px",
    #          hAxis=input$metric_x,
    #          vAxis=input$metric_y,
    #          pointSize=1)
    # })

    output$map <- renderLeaflet({
        # metric_selected_new <- metric_selected_update()
        leaflet() %>%
            addProviderTiles("OpenStreetMap.Mapnik") %>%
            setView(lng = -98.5795, lat = 39.8283, zoom = 4) %>%
            addPolygons(data=USA_state, stroke=FALSE, smoothFactor=0.2, fillOpacity=0.4,
                        fillColor= ~mypal(temp[["unemployment"]]),
                        popup = paste("State: ", temp$NAME_1, "<br>", "Unemployment: ", temp[["unemployment"]], "<br>")) %>%
            addLegend(position="bottomleft", pal=mypal, values=temp[["unemployment"]], title="Unemployment", opacity=1)
    })
    
    output$scatter <- renderGvis(
        gvisScatterChart(scatter_data(),
                         options=list(
                             width="1000px", height="400px",
                             pointSize=1,
                             hAxis=paste("{title:'", input$metric_x, "'}"),
                             vAxis=paste("{title:'", input$metric_y, "'}"),
                             trendlines="0"
                         ))
    )
    
    output$table <- DT::renderDataTable({
        datatable(counties_df, rownames=FALSE)
    })

})
