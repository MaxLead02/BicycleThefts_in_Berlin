library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)
library(leaflet)
library(DBI)
library(RPostgres)
library(RPostgreSQL)
library(readr)
library(tidyr)
library(dplyr)
library(stringi)
# Database connection settings
host <- "your_host"
port <- 5432
dbname <- "your_dbname"
user <- "your_username"
password <- "your_password"

# Create a connection to the database
con <- dbConnect(RPostgres::Postgres(), 
                 host = host, 
                 port = port, 
                 dbname = dbname, 
                 user = user, 
                 password = password)


#SET UP THE POSTGRESQL

# Administrative_Boundaries Table
dbSendQuery(con, "
CREATE TABLE Administrative_Boundaries (
    Gemeinde_schluessel VARCHAR(255) PRIMARY KEY,
    Gemeinde_name VARCHAR(255),
    Land_name VARCHAR(255)
)
")

# Urban_Planning_Regions Table
dbSendQuery(con, "
CREATE TABLE Urban_Planning_Regions (
    PLR_ID VARCHAR(255) PRIMARY KEY,
    PLR_NAME VARCHAR(255),
    BEZ VARCHAR(255),
    STAND TIMESTAMP,
    GROESSE_M2 FLOAT,
    latitude FLOAT,
    longitude FLOAT
)")
# Add a foreign key 
dbSendQuery(con, "
ALTER TABLE Urban_Planning_Regions 
ADD CONSTRAINT fk_BEZ 
FOREIGN KEY (BEZ) 
REFERENCES Administrative_Boundaries (Gemeinde_schluessel)
")


# Bicycle_Thefts Table
dbSendQuery(con, "
CREATE TABLE Bicycle_Thefts (
    id INT PRIMARY KEY,
    ANGELEGT_AM TIMESTAMP,
    TATZEIT_ANFANG_DATUM TIMESTAMP,
    TATZEIT_ANFANG_STUNDE INT,
    TATZEIT_ENDE_DATUM TIMESTAMP,
    TATZEIT_ENDE_STUNDE INT,
    LOR VARCHAR(255),
    SCHADENSHOEHE FLOAT,
    VERSUCH BOOLEAN,
    ART_DES_FAHRRADS VARCHAR(255),
    DELIKT VARCHAR(255),
    ERFASSUNGSGRUND VARCHAR(255)
)
")
# Add a foreign key
dbSendQuery(con, "
ALTER TABLE Bicycle_Thefts 
ADD CONSTRAINT fk_lor 
FOREIGN KEY (lor) 
REFERENCES Urban_Planning_Regions (PLR_ID)
")

#PREPROCESS THE DATA

# Load your data
fahrraddiebstahl_data <- read.csv("your_path_to_the_file/Fahrraddiebstahl.csv")
lor_planungsraeume_data <- read_csv("your_path_to_the_file/lor_plan_rm_with_coord.csv")
bezirksgrenzen_data <- read_csv("your_path_to_the_file/bezirksgrenzen.csv")

# Delete first Nulls in Gemeinde_schluessel
bezirksgrenzen_data$Gemeinde_schluessel <- sub("^0", "", bezirksgrenzen_data$Gemeinde_schluessel)
# Add Null, if LOR is a 7-digit number 
fahrraddiebstahl_data$LOR <- ifelse(nchar(fahrraddiebstahl_data$LOR) == 7, paste0("0", fahrraddiebstahl_data$LOR), fahrraddiebstahl_data$LOR)

# Remove columns from the data frame
lor_planungsraeume_data <- subset(lor_planungsraeume_data, select = -c(Name, description, timestamp, begin, end, altitudeMode, tessellate, extrude, visibility, drawOrder, icon))
bezirksgrenzen_data <- subset(bezirksgrenzen_data, select = -c(gml_id, Land_schluessel, Schluessel_gesamt))

# Checking missing values
fahrraddiebstahl_data %>% replace_na(list()) %>% summary()
lor_planungsraeume_data %>% replace_na(list()) %>% summary()
bezirksgrenzen_data %>% replace_na(list()) %>% summary()

# Check for duplicates
fahrraddiebstahl_data %>% distinct() %>% count()
lor_planungsraeume_data %>% distinct() %>% count()
bezirksgrenzen_data %>% distinct() %>% count()

# Convert data to UTF-8
fahrraddiebstahl_data <- mutate_if(fahrraddiebstahl_data, is.character, stri_encode, "", "UTF-8")

# Add a new column 'id' as primary key
fahrraddiebstahl_data$id <- seq_len(nrow(fahrraddiebstahl_data))

# Write data into the database
dbWriteTable(con, "bicycle_thefts", fahrraddiebstahl_data, row.names = FALSE, overwrite = TRUE)
dbWriteTable(con, "urban_planning_regions", lor_planungsraeume_data, row.names = FALSE, overwrite = TRUE)
dbWriteTable(con, "administrative_boundaries", bezirksgrenzen_data, row.names = FALSE, overwrite = TRUE)


# Set up the Web Application
ui <- dashboardPage(
  dashboardHeader(title = "Bike Theft"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Filters", tabName = "filters", icon = icon("filter")),
      menuItem("Map", tabName = "map", icon = icon("map"))
    )
  ),
  dashboardBody(
    skin = "purple",
    tabItems(
      tabItem(tabName = "filters",
              fluidRow(
                box(
                  title = "Filters",
                  status = "primary", 
                  solidHeader = TRUE,
                  width = 12,
                  selectInput("time", "Hour of the Day:", choices = as.character(0:23), selected = "0"),
                  selectInput("bikeType", "Type of Bike:", choices = c("ALL", "Damenfahrrad", "Herrenfahrrad", "Mountainbike", "Fahrrad", "Rennrad", "Kinderfahrrad", "diverse Fahrräder", "Lastenfahrrad")), 
                  sliderInput("damage", "Damage Range:", min = 0, max = 10000, value = c(0, 10000)),
                  actionButton("proceed", "Proceed", class = "btn-primary")
                )
              )
      ),
      tabItem(tabName = "map",
              fluidRow(
                box(
                  title = "Bike Theft Map",
                  status = "primary", 
                  solidHeader = TRUE,
                  width = 12,
                  leafletOutput("map", width = "100%", height = "650px") # Adjust the size here
                )
              )
      )
    )
  )
)


server <- function(input, output, session) {
  
  data <- reactive({
    req(input$proceed)
    
    query <- paste0('SELECT "bicycle_thefts"."ART_DES_FAHRRADS", "bicycle_thefts"."SCHADENSHOEHE", "urban_planning_regions"."longitude", 
            "urban_planning_regions"."latitude", "urban_planning_regions"."PLR_NAME" 
            FROM "bicycle_thefts"
            JOIN "urban_planning_regions" ON "bicycle_thefts"."LOR" = "urban_planning_regions"."PLR_ID"
            WHERE "TATZEIT_ANFANG_STUNDE" = \'', input$time, '\'',
                    ' AND "SCHADENSHOEHE" >= ', input$damage[1],
                    ' AND "SCHADENSHOEHE" <= ', input$damage[2])
    
    if (input$bikeType != "ALL") {
      query <- paste0(query, " AND \"bicycle_thefts\".\"ART_DES_FAHRRADS\" = '", input$bikeType, "'")
    }
    dbGetQuery(con, query)
  })
  
  output$map <- renderLeaflet({
    req(data())
    
    leaflet() %>%
      addTiles() %>%
      addCircleMarkers(data = data(), ~ longitude, ~ latitude, popup = ~ paste("Type of bike: ", ART_DES_FAHRRADS, "<br>", 
                                                                               "Area: ", PLR_NAME, "<br>", 
                                                                               "Damage: ", SCHADENSHOEHE, "<br>"))
  })
  
  observeEvent(input$proceed, {
    updateTabItems(session, "sidebar", selected = "map")
  })
}


# Loao the Web Application
shinyApp(ui = ui, server = server)

# Disconnect from the PostgreSQL-Server
dbDisconnect(con)