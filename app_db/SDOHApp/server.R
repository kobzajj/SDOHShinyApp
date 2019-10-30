#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

shinyServer(function(input, output, session) {
    
    dbname = "./sdoh.sqlite"
    source("helpers.R")
    conn <- dbConnector(session, dbname = dbname)
    
    sdoh_df_metric_state <- na.omit(dbGetDataStates(conn, "state, unemployment"))
    sdoh_df_metric_state$state <- abbr2state(as.character(sdoh_df_metric_state$state))
    sdoh_df_metric_state <- na.omit(sdoh_df_metric_state)
    temp <- merge(USA_state, sdoh_df_metric_state, by.x="NAME_1", by.y="state", all.x=TRUE)
    mypal <- colorNumeric(palette="viridis", domain=temp[["unemployment"]], na.color="grey")
    
    observeEvent(input$cat_selected, {
        subcat_choice_map <- unique(dbGetDataMetrics(conn, "subcategory", input$cat_selected, "all", "all", "all")$subcategory)
        updateSelectizeInput(
            session, "subcat_selected",
            choices = subcat_choice_map,
            selected = subcat_choice_map[1]
        )
        metric_choice_map <- unique(dbGetDataMetrics(conn, "[metric.name]", input$cat_selected, input$subcat_selected, "all", "all")$metric.name)
        updateSelectizeInput(
            session, "metric_selected",
            choices = metric_choice_map,
            selected = metric_choice_map[1]
        )
    })
    
    observeEvent(input$subcat_selected, {
        metric_choice_map <- unique(dbGetDataMetrics(conn, "[metric.name]", input$cat_selected, input$subcat_selected, "all", "all")$metric.name)
        updateSelectizeInput(
            session, "metric_selected",
            choices = metric_choice_map,
            selected = metric_choice_map[1]
        )
    })
    
    observeEvent(input$cat_x, {
        subcat_choice_x <- unique(dbGetDataMetrics(conn, "subcategory", input$cat_x, "all", "all", "all")$subcategory)
        updateSelectizeInput(
            session, "subcat_x",
            choices = subcat_choice_x,
            selected = subcat_choice_x[1]
        )
        metric_choice_x <- unique(dbGetDataMetrics(conn, "[metric.name]", input$cat_x, input$subcat_x, "all", "all")$metric.name)
        updateSelectizeInput(
            session, "metric_x",
            choices = metric_choice_x,
            selected = metric_choice_x[1]
        )
    })
    
    observeEvent(input$subcat_x, {
        metric_choice_x <- unique(dbGetDataMetrics(conn, "[metric.name]", input$cat_x, input$subcat_x, "all", "all")$metric.name)
        updateSelectizeInput(
            session, "metric_x",
            choices = metric_choice_x,
            selected = metric_choice_x[1]
        )
    })
    
    observeEvent(input$cat_y, {
        subcat_choice_y <- unique(dbGetDataMetrics(conn, "subcategory", input$cat_y, "all", "all", "all")$subcategory)
        updateSelectizeInput(
            session, "subcat_y",
            choices = subcat_choice_y,
            selected = subcat_choice_y[1]
        )
        metric_choice_y <- unique(dbGetDataMetrics(conn, "[metric.name]", input$cat_y, input$subcat_y, "all", "all")$metric.name)
        updateSelectizeInput(
            session, "metric_y",
            choices = metric_choice_y,
            selected = metric_choice_y[1]
        )
    })
    
    observeEvent(input$subcat_y, {
        metric_choice_y <- unique(dbGetDataMetrics(conn, "[metric.name]", input$cat_y, input$subcat_y, "all", "all")$metric.name)
        updateSelectizeInput(
            session, "metric_y",
            choices = metric_choice_y,
            selected = metric_choice_y[1]
        )
    })
    
    observeEvent(input$metric_selected, {

        if (input$metric_selected != "") {
            metric_selected_new <- as.character(dbGetDataMetrics(conn, "[metric.id]", "all", "all", "all", input$metric_selected))
            
            proxy <- leafletProxy("map")
            
            if (input$detail_selected == "State") {
                sdoh_df_metric_state <- na.omit(dbGetDataStates(conn, paste0("state, [", metric_selected_new, "]")))
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
                sdoh_df_metric_county <- na.omit(dbGetDataCounties(conn, paste0("state, county, [", metric_selected_new, "]")))
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
        na.omit(dbGetDataCounties(conn, paste0("[", 
                                               as.character(dbGetDataMetrics(conn, "[metric.id]", "all", "all", "all", input$metric_x)), 
                                               "], [", 
                                               as.character(dbGetDataMetrics(conn, "[metric.id]", "all", "all", "all", input$metric_y)),
                                               "]")))
    })
    
    hist_data <- reactive({
        dbGetDataStates(conn, paste0("[", as.character(dbGetDataMetrics(conn, "[metric.id]", "all", "all", "all", input$metric_selected)), "]"))
    })
    
    output$maxBox <- renderInfoBox({
        max_value <- max(na.omit(hist_data()))
        max_state <- abbr2state(dbGetDataStates(conn, "state", as.character(dbGetDataMetrics(conn, "[metric.id]", "all", "all", "all", input$metric_selected)), max_value))
        infoBox(max_state, round(max_value, 3), icon = icon("hand-o-up"))
    })
    
    output$minBox <- renderInfoBox({
        min_value <- min(na.omit(hist_data()))
        min_state <- abbr2state(dbGetDataStates(conn, "state", as.character(dbGetDataMetrics(conn, "[metric.id]", "all", "all", "all", input$metric_selected)), min_value))
        infoBox(min_state, round(min_value, 3), icon = icon("hand-o-down"))
    })
    
    output$avgBox <- renderInfoBox({
        infoBox(paste("Average ", input$metric_selected),
                round(as.numeric(dbGetDataMetrics(conn, "[natl.avg]", "all", "all", "all", input$metric_selected)), 3), 
                icon = icon("calculator"), fill=TRUE)
    })

    output$map <- renderLeaflet({
        leaflet() %>%
            addProviderTiles("OpenStreetMap.Mapnik") %>%
            setView(lng = -98.5795, lat = 39.8283, zoom = 4) %>%
            addPolygons(data=USA_state, stroke=FALSE, smoothFactor=0.2, fillOpacity=0.4,
                        fillColor= ~mypal(temp[["unemployment"]]),
                        popup = paste("State: ", temp$NAME_1, "<br>", "Unemployment: ", temp[["unemployment"]], "<br>")) %>%
            addLegend(position="bottomleft", pal=mypal, values=temp[["unemployment"]], title="Unemployment", opacity=1)
    })
    
    output$hist <- renderGvis(gvisHistogram(hist_data(),
                                            options=list(
                                                hAxis=paste("{title:'", input$metric_selected, "'}"),
                                                vAxis="{title:'Count'}",
                                                legend="{position: 'none'}"
                                            )))
    
    output$scatter <- renderGvis(
        gvisScatterChart(scatter_data(),
                         options=list(
                             width="1000px", height="400px",
                             pointSize=1,
                             hAxis=paste("{title:'", input$metric_x, "'}"),
                             vAxis=paste("{title:'", input$metric_y, "'}"),
                             trendlines="0",
                             legend="{position: 'none'}"
                         ))
    )

    table_df <- eventReactive(input$table_detail, {
        
        if (input$table_detail == "State") {
            dbGetDataStates(conn, "*")
        } else {
            dbGetDataCounties(conn, "*")
        }
    })
    
    output$table <- DT::renderDataTable({
        datatable(table_df(), rownames=FALSE)
    })

})
