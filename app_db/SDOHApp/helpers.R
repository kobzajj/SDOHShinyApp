
dbConnector <- function(session, dbname) {
  require(RSQLite)
  ## setup connection to database
  conn <- dbConnect(drv = SQLite(), 
                    dbname = dbname)
  ## disconnect database when session ends
  session$onSessionEnded(function() {
    dbDisconnect(conn)
  })
  ## return connection
  conn
}

dbGetDataMetrics <- function(conn, fields, cat_cond, subcat_cond, metric_id_cond, metric_name_cond) {
  query <- paste("SELECT",  fields, "FROM metrics",
                 "WHERE category IN (",
                 ifelse(cat_cond == "all", "SELECT category from metrics", 
                        paste0("'", as.character(cat_cond), "'")), ")",
                 "AND subcategory IN (",
                 ifelse(subcat_cond == "all", "SELECT subcategory from metrics",
                        paste0("'", as.character(subcat_cond), "'")), ")",
                 "AND [metric.id] IN (",
                 ifelse(metric_id_cond == "all", "SELECT [metric.id] from metrics",
                        paste0("'", as.character(metric_id_cond), "'")), ")",
                 "AND [metric.name] IN (",
                 ifelse(metric_name_cond == "all", "SELECT [metric.name] from metrics",
                        paste0("'", as.character(metric_name_cond), "'")), ")"
                 )
  as.data.table(dbGetQuery(conn = conn,
                           statement = query))
}

dbGetDataStates <- function(conn, fields, value_metric=NA, value_cond=NA) {
  query <- paste("SELECT", fields, "FROM states",
                 ifelse(!is.na(value_metric),
                        paste("WHERE", paste0("round([", value_metric, "], 5)"), "=", paste0("round(", value_cond, ", 5)")),"")
                 )
  as.data.table(dbGetQuery(conn = conn,
                           statement = query))
}

dbGetDataCounties <- function(conn, fields) {
  query <- paste("SELECT", fields, "FROM counties")
  as.data.table(dbGetQuery(conn = conn,
                           statement = query))
}
