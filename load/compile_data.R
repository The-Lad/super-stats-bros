# load_data.R
library(rvest)
library(jsonlite)
library(dplyr)
library(stringr)
source('data_constants.R', encoding = 'UTF-8')

source('load/get_char_attr_data.R')
source('load/get_usage_and_winning.R')
source('load/get_tournament_results.R')
source('load/get_tier_list.R')
source('load/get_icons.R')
source('load/get_colors.R')
constituent_chars = c('Squirtle', 'Ivysaur', 'Charizard', 'Popo', 'Nana')

char_data = full_join(char_attrs, tibble::enframe(usage[!names(usage) %in% constituent_chars], "character", "usage"))
char_data = left_join(char_data, tibble::enframe(winning[!names(winning) %in% constituent_chars], "character", "win_ratio"))

# Add usage and win ratio
char_data$usage = round(char_data$usage, 4) 
char_data$games_lost = as.numeric(str_remove(str_extract(char_data$win_ratio, '[^\\s]+$'), ',')) 
char_data$games_won = as.numeric(str_remove(str_extract(char_data$win_ratio, '^[^-]+'), ','))
char_data$win_ratio = round(char_data$games_won / (char_data$games_lost + char_data$games_won), 4)

# Add tournament results and top player characters
char_data = left_join(char_data, major_tournament_chars, by = c('character' = '.')) 
char_data = left_join(char_data, top_player_chars, by = c('character' = '.')) 
char_data$tournament_win_freq[is.na(char_data$tournament_win_freq) & !char_data$character %in% constituent_chars] = 0
char_data$top_player_freq[is.na(char_data$top_player_freq) & !char_data$character %in% constituent_chars] = 0

# Add PGR Top 50 7.0.0 tier list from Feb 19 2020
if ('tier_list' %in% ls()) char_data = left_join(char_data, select(tier_list, -raw))

# Add local and URL paths to character icons
char_data = left_join(char_data, tibble::enframe(files, "character", "icon_path"))
char_data = left_join(char_data, tibble::enframe(icons, "character", "icon_url_path"))

if ('background_colors_clean' %in% ls()) {
  char_data = left_join(char_data, background_colors_clean)
  char_data$color[char_data$character== 'Squirtle'] = "#a2d7d5"
  char_data$color[char_data$character== 'Charizard'] = "#ee8328"
  char_data$color[char_data$character== 'Ivysaur'] = "#67cfa5"
  char_data$color[char_data$character== 'Nana'] = "#ff6699"
  char_data$color[is.na(char_data$color)] = "#ffffff"
} else if (file.exists('data/dont_commit/smash_colors.xlsx')) {
  char_colors <- readxl::read_excel('data/dont_commit/smash_colors.xlsx', sheet = 'Characters')
  char_data = left_join(char_data, select(char_colors, character = CHARACTER, color = `Colour hex code`, series_color = `Series colour`))
  char_data$color[is.na(char_data$color)] = "#ffffff"
}

saveRDS(char_data, 'data/dont_commit/char_stats.rds')
