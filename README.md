**Interactive Geospatial Visualization of Bicycle Thefts in Berlin**

This repository contains the code for a Shiny web application that provides interactive and informative visualization of bicycle theft data across Berlin.

**Project Description**

This Shiny app generates a dynamic map, allowing users to visually explore the distribution and density of bicycle thefts in relation to regional attributes across Berlin. Users can zoom in and out, click on regions to get more detailed data, and filter data based on parameters such as time, bike type, and damage range.

**Getting Started**

These instructions will help you get a copy of the project up and running on your local machine.

**Prerequisites**

You'll need the following installed on your machine:

R
RStudio
PostgreSQL
Required R packages: shiny, shinydashboard, shinyWidgets, shinyjs, leaflet, DBI, RPostgres, RPostgreSQL, readr, tidyr, dplyr, stringi.

**Installation**

Install necessary R packages: You can do this in RStudio by running the command install.packages(c("shiny", "shinydashboard", "shinyWidgets", "shinyjs", "leaflet", "DBI", "RPostgres", "RPostgreSQL", "readr", "tidyr", "dplyr", "stringi")).

Set up the PostgreSQL database as per the instructions in the script.

**Usage**

To run the Shiny app:

1) Open the project in RStudio.

2) Run the script.

4) Navigate to the Shiny web application in your web browser.

**1) Introduction**

This project is an interactive visualization of bicycle thefts in Berlin, Germany. It allows users to explore theft incidents based on various parameters such as time of the day, type of bicycle, and damage range. The data is visually represented on a map, giving users a geographic perspective of the crimes.
The project uses R language and the Shiny package to build a dynamic, web-based dashboard.

**1.1) Why Shiny?**

Shiny is an R package that makes it easy to build interactive web applications straight from R. It helps you turn your analyses into interactive web applications without needing HTML, CSS, or JavaScript knowledge. Here's why we chose Shiny:

•	Interactivity: Shiny applications have built-in interactivity, meaning no extra code is required to make your applications interactive. You can easily collect inputs from the user, manipulate data based on those inputs, and provide reactive outputs.

•	Versatility: Shiny has built-in support for various web-based tools and formats such as sliders, checkboxes, tables, and plots. This makes it easy to represent and interact with data in many ways.

•	Integration: Shiny is fully integrated with R and the rest of the R ecosystem. This means that you can leverage all the statistical and graphical power of R, including its numerous packages, in your Shiny applications.

**2) Code Annotation**

**2.1) Packages**

The code uses the following R packages:

•	shiny, shinydashboard, shinyWidgets, shinyjs: These are used to build the Shiny application. They provide tools for creating the web application, designing the dashboard, adding widgets for user interaction, and enabling JavaScript operations respectively.

•	leaflet: This is used to create interactive maps.

•	DBI, RPostgres, RPostgreSQL: These are used to manage the PostgreSQL database connection and operations.

•	readr, tidyr, dplyr: These are part of the 'tidyverse' suite of packages. They are used for data manipulation and transformation.

•	stringi: This package provides string processing capabilities and is used for character encoding conversion.

**2.2) Code Overview**

The script is divided into several parts:

1.	Database connection setup and table creation.

2.	Data preprocessing, which includes reading CSV files, removing unnecessary columns, checking and handling missing values, checking for duplicates, and converting character data to UTF-8 encoding.

3.	Writing preprocessed data into the database.

4.	Creating the Shiny application, which includes designing the UI and defining server-side operations.

**3) Data Manipulation**

The dataset comes from three CSV files:

•	Fahrraddiebstahl.csv: Contains information about the bicycle thefts.

•	lor_plan_rm_with_coord.csv: Contains data about urban planning regions.

•	bezirksgrenzen.csv: Contains data about administrative boundaries.

**3.1) Modifications on lor_plan_rm_with_coord.csv**

The lor_plan_rm_with_coord.csv (the previous name lor_planungsraeume_2021.csv) file originally did not have the longitude and latitude columns, which are necessary for the geospatial visualization in our web application. To address this, a Python script was written to add these two columns. The script uses the OpenCage Geocoder API to find the longitude and latitude for each planning region.

**3.2) Data Cleaning**

The following data cleaning steps are implemented:

•	Leading zeroes are removed from the Gemeinde_schluessel column in the bezirksgrenzen.csv file.

•	If the LOR value in the Fahrraddiebstahl.csv file is a 7-digit number, a leading zero is added.

•	Unnecessary columns are removed from the lor_plan_rm_with_coord.csv and bezirksgrenzen.csv files.

•	The dataset is checked for missing values and duplicates.

•	Character data is converted to UTF-8 encoding.

**3.3) Database Integration**

The cleaned data is then written into three different tables in a PostgreSQL database, namely the bicycle_thefts, urban_planning_regions, and administrative_boundaries tables.

**Contact**

If you want to contact me, you can reach me at danilchikmax@gmail.com.
