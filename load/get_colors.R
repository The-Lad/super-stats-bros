# Colour data
# library(rvest)
# library(dplyr)
# library(stringr)


# Source of sheet is https://www.smashbros.com/assets_v2/css/fighter/mario.css
background_colors = list()
for (name in smash_css_names) {
  background_colors[[name]] <-  read_html(paste0('https://www.smashbros.com/assets_v2/css/fighter/',name,'.css')) %>% html_text() %>% str_extract('.fighter-bg{.*}')
}
