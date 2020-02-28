###################################
## SUPER STATS BROS v0.3         ##
## Author: Nicholas Meuli        ##
###################################
suppressMessages({
library(conflicted)
library(shiny)
library(shinyWidgets)
library(shinyjs)
library(shinydashboard)
library(highcharter)
library(DT)
library(dplyr)
library(stringr)
})
conflict_prefer("filter", "dplyr")
conflict_prefer('dataTableOutput', 'DT')
conflict_prefer('renderDataTable', 'DT')
conflict_prefer('box', 'shinydashboard')

if (file.exists('data/dont_commit/char_stats.rds')) {
  source('load_app_data.R')
} else {
  source('compile_data.R')
}

source('ui.R')