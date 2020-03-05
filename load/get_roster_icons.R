source('data_constants.R')
if (!dir.exists('pics')) dir.create('pics')
if (!dir.exists('pics/roster')) dir.create('pics/roster')

tryCatch({
  for (name in char_list$smash_css_names[char_list$smash_css_names != ""]) download_html(paste0('https://www.smashbros.com/assets_v2/img/fighter/thumb_a/', name, '.png'), paste0('pics/roster/', name, '.png'))
  roster_images = tibble(character = char_list$app_names[char_list$smash_css_names != ""],
                      roster_image = paste0('pics/roster/', char_list$smash_css_names[char_list$smash_css_names != ""], '.png'))
}, error = function(e) {
  ign_pics = read_html('https://www.ign.com/wikis/super-smash-bros-ultimate/Characters_and_Roster') %>% 
    html_nodes('.jsx-1165820633') %>% 
    html_attr('src')
  files =  ign_pics %>% str_extract( "([^/]+[/]?)?.jpg") %>% str_remove_all("Smash|[T|t]humb|\\.jpg") %>% 
    str_replace_all(mapped_names) %>% str_remove_all(" ") %>% paste0('pics/roster/',.,'.jpg')
  names(files) = ign_pics
  
  if (any(!file.exists(files))) {
    sapply(ign_pics, function(x) download.file(x, files[x]))
  }
  
  roster_images = tibble(character = str_remove_all(files, "pics/roster/|\\.jpg"), roster_image = files) %>% 
    mutate(character = str_replace_all(character, '([a-z])([A-Z])', '\\1 \\2') %>%
             str_replace_all('([a-z])&([A-Z])', '\\1 & \\2') %>% 
             str_replace_all('([A-Z])([A-Z])', '\\1 \\2')) %>% 
    rbind(tibble(character = c('Mii Brawler', 'Mii Swordfighter', 'Mii Gunner'), 
                 roster_image = files[str_detect(names(files), 'MiiFighter')]))
  
}
)
