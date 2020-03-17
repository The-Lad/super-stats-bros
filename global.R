###################################
## SUPER STATS BROS v0.3         ##
## Author: Nicholas Meuli        ##
###################################
# packages <-  c("dplyr", "stringr", "shiny","shinyjs", "highcharter", "shinydashboard", "conflicted", "DT", "shinyWidgets")
# for (i in packages){
#   if (!is.element(i,installed.packages()[,1])) {
#     install.packages(i,dependencies = TRUE)
#   }
# }
#suppressMessages({lapply(packages, library, character.only = TRUE)})

#library(conflicted)
library(shiny)
library(shinyjs)
library(shinydashboard)
library(shinyWidgets)
library(DT)
library(dplyr)
library(stringr)
library(highcharter)
library(waiter)

# conflict_prefer("filter", "dplyr")
# conflict_prefer('dataTableOutput', 'DT')
# conflict_prefer('renderDataTable', 'DT')
# conflict_prefer('box', 'shinydashboard')

if (file.exists('data/dont_commit/char_stats.rds')) {
  source('load_app_data.R')
} else {
  source('compile_data.R')
  source('load_app_data.R')
}

source('ui.R')