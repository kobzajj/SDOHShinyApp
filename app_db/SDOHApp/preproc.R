library(RSQLite)
library(data.table)


dbname = "./sdoh.sqlite"
## read csv files
counties_dt <- fread(input = 'data/sdoh_counties.csv',
              sep = ",",
              header = TRUE)
states_dt <- fread(input = 'data/sdoh_states.csv',
                     sep = ",",
                     header = TRUE)
metrics_dt <- fread(input = 'data/metric_table.csv',
                   sep = ",",
                   header = TRUE)
## connect to database
conn <- dbConnect(drv = SQLite(), 
                  dbname = dbname)
## write tables to database
dbWriteTable(conn = conn,
             name = "counties",
             value = counties_dt,
             overwrite = TRUE)
dbWriteTable(conn = conn,
             name = "states",
             value = states_dt,
             overwrite = TRUE)
dbWriteTable(conn = conn,
             name = "metrics",
             value = metrics_dt,
             overwrite = TRUE)
## list tables
dbListTables(conn)
## disconnect
dbDisconnect(conn)
