icon_page = read_html('http://www.ssbwiki.com/Category:Head_icons_(SSBU)')
icons = icon_page %>% html_nodes('img') %>% html_attr('src') %>% str_subset('120px|Mii|Charizard|Squirtle|Ivysaur')
files = paste0('pics/', str_extract(icons, '[^/]+$'))

if (!dir.exists('pics')) dir.create('pics')
if (any(!file.exists(files))) {
  sapply(paste0('http://www.ssbwiki.com/', icons[!file.exists(files)]), function(x) download_html(x, paste0('pics/', str_extract(x, '[^/]+$'))))
}

names(files) = str_remove_all(files, 'pics/[120px-]*|HeadSSBU[Website]*.png') %>% str_replace_all("([a-z])([A-Z])", "\\1 \\2") %>% str_replace_all(mapped_names)
icons = paste0('https://www.ssbwiki.com', icons)
names(icons) = names(files)
files = c(files, setNames( rep(files[names(files) == 'Ice Climbers'], 2), c('Nana', 'Popo')))
icons = c(icons,  setNames( rep(icons[names(icons) == 'Ice Climbers'], 2), c('Nana', 'Popo')))
