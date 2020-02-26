# library(rvest)
# library(jsonlite)
# library(dplyr)
#source('data_constants.R')


# Get some from the site
stat_site = 'https://kuroganehammer.com/'
char_stat_pages = read_html(paste0(stat_site, 'Ultimate/Attributes')) %>% html_nodes('#AutoNumber1 a') %>% html_attr('href')

raw_char_data = list()
raw_char_data = sapply(1:length(char_stat_pages), function(num) {
  read_html(paste0(stat_site, char_stat_pages[num])) %>% 
    html_table() %>% .[lapply(., length) > 1]
})
names(raw_char_data) = str_remove(char_stat_pages, '/Ultimate/')

char_attrs = raw_char_data %>% 
  purrr::map_df(bind_rows) %>% 
  filter(!is.na(CHARACTER) & CHARACTER != "") %>%
  select(-RANK, -`SPEED INCREASE`, -`MAX ADDITIONAL`, -`BASE VALUE`) %>% 
  mutate(CHARACTER = str_replace_all(CHARACTER, mapped_names)) %>% 
  group_by(CHARACTER) %>% 
  mutate_if(is.numeric, function(x) {first(x[!is.na(x)])}) %>% 
  ungroup() %>% 
  select_if(function(x) {!all(is.na(x))}) %>% 
  distinct() %>%
  rename(`AIR ACCELERATION` = `TOTAL`)  %>%
  rename_all(tolower) %>%
  rename_at(vars(contains('max ')), function(x) str_remove(x, 'max ')) %>%
  rename_at(vars(contains(' value')), function(x) str_remove(x, ' value')) %>%
  rename_all(function(x) str_replace_all(x, ' ', '_'))


# Get remaining ones from the API (not complete yet)
char_raw = httr::GET('https://api.kuroganehammer.com/api/movements?game=ultimate',
                     httr::add_headers('content-type' = 'application/json'))
char_json = jsonlite::fromJSON(httr::content(char_raw, 'text'), flatten = TRUE)
char_api = as_tibble(char_json)

missing_chars = setdiff(char_list$app_names, char_attrs$character)

char_api = char_api %>%
  #filter(Owner %in% missing_chars) %>%
  select(Owner, Name, Value) %>%
  tidyr::spread(key = 'Name', value = 'Value') %>%
  rename_all(tolower) %>%
  rename_all(function(x) str_replace_all(x, ' ', '_')) %>%
  mutate_at(vars(one_of(colnames(char_attrs))), as.numeric) %>%
  rename(character = owner) %>%
  mutate(character = str_replace_all(character, mapped_names)) 

char_attrs = char_attrs %>%
  left_join(char_api) %>%
  full_join(filter(char_api, character %in% missing_chars)) %>% 
  mutate_if(is.numeric, function(x) ifelse(is.na(x) & .$character %in% c('Popo', 'Nana'), x[.$character == 'Ice Climbers'], x)) %>%  
  mutate_if(is.numeric, function(x) ifelse(is.na(x) & .$character == 'Ice Climbers', x[.$character == 'Popo'], x) ) 

#stringdist::stringdist(names(mapped_names), mapped_names) #RecordLinkage::levenshteinSim
#names(mapped_names) = paste0('^', names(mapped_names), '$')

