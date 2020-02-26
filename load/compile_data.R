# load_data.R
library(rvest)
library(jsonlite)
library(dplyr)
library(stringr)
source('data_constants.R', encoding = 'UTF-8')

source('load/get_char_attr_data.R')
source('load/get_icons.R')
source('load/get_usage_and_winning.R')
source('load/get_tournament_results.R')
source('load/get_colors.R')

char_attrs = full_join(char_attrs, tibble::enframe(usage, "character", "usage"))
char_attrs = left_join(char_attrs, tibble::enframe(winning, "character", "win_ratio"))

# Add usage and win ratio
char_attrs$usage = round(char_attrs$usage, 4) 
char_attrs$games_lost = as.numeric(str_remove(str_extract(char_attrs$win_ratio, '[^\\s]+$'), ',')) 
char_attrs$games_won = as.numeric(str_remove(str_extract(char_attrs$win_ratio, '^[^-]+'), ','))
char_attrs$win_ratio = round(char_attrs$games_won / (char_attrs$games_lost + char_attrs$games_won), 4)

# Add tournament results and top player characters
char_attrs = left_join(char_attrs, major_tournament_chars, by = c('character' = '.')) 
char_attrs = left_join(char_attrs, top_player_chars, by = c('character' = '.')) 
char_attrs$tournament_win_freq[is.na(char_attrs$tournament_win_freq)] = 0
char_attrs$top_player_freq[is.na(char_attrs$top_player_freq)] = 0

# Add local and URL paths to character icons
char_attrs = left_join(char_attrs, tibble::enframe(files, "character", "icon_path"))
char_attrs = left_join(char_attrs, tibble::enframe(icons, "character", "icon_url_path"))

# Ensure Popo and Nana don't show up
char_attrs[char_attrs$character %in% c('Popo', 'Nana'), c('usage', 'win_ratio', 'games_won', 'games_lost', 'top_player_freq', 'tournament_win_freq')] = NA

if ('background_colors' %in% ls()) {
  char_attrs = left_join(char_attrs, background_colors)
  char_attrs$color[is.na(char_attrs$color)] = "#000000"
} else if (file.exists('data/smash_colors.xlsx')) {
  char_colors <- readxl::read_excel('data/smash_colors.xlsx', sheet = 'Characters')
  char_attrs = left_join(char_attrs, select(char_colors, character = CHARACTER, color = `Colour hex code`, series_color = `Series colour`))
  char_attrs$color[is.na(char_attrs$color)] = "#000000"
}

saveRDS(char_attrs, 'data/char_stats.rds')
