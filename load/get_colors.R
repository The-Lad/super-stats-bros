# Colour data
# library(rvest)
# library(dplyr)
# library(stringr)


# Source of sheet is https://www.smashbros.com/assets_v2/css/fighter/mario.css
background_colors = list()
for (name in char_list$smash_css_names) {
  background_colors[[name]] <-  read_html(paste0('https://www.smashbros.com/assets_v2/css/fighter/',name,'.css')) %>% html_text() %>% str_replace('.*\\.fighter-bg\\{background:([^\n\\}]*).*', '\\1') %>% str_remove('\n')
}
background_colors = stack(background_colors) %>% rename(character = ind, color = values) %>% mutate(character = str_replace_all(character,  setNames(as.character(char_list$app_names), paste0('^', char_list$smash_css_names, '$'))))
