# USAGE AND WINNING
usage_data = tryCatch(read_html('https://ssbworld.com/characters/usage/'),
                         error = function(e) {html_session('https://ssbworld.com/characters/win-percentage/') %>% 
                             follow_link('view character usage')})

usage = usage_data %>% html_nodes('.player-meta div')  %>% html_text() %>% str_remove_all(',| |\\(|\\)') %>% sapply(function(x) eval(parse(text = x)))
usage_chars=  usage_data %>% html_nodes('#main-container a') %>% .[str_detect(.,  'character-profiles/')] %>% html_attr('href') %>% str_extract('(?!.*/).+$')
names(usage) = usage_chars %>% str_replace_all('-', ' ') %>% str_replace_all('and', '&') %>%  str_to_title()  

winning_data = tryCatch(read_html('https://ssbworld.com/characters/win-percentage/'),
                         error = function(e) {html_session('https://ssbworld.com/characters/usage/') %>%
                             follow_link('View Character Win Percentage')})


winning = winning_data %>% html_nodes('.player-meta div')%>% html_text() %>% str_remove_all('\\(|\\)')
winning_chars=  winning_data %>% html_nodes('#main-container a') %>% .[str_detect(.,  'character-profiles/')] %>% html_attr('href') %>% str_extract('(?!.*/).+$')
names(winning) = winning_chars %>% str_replace_all('-', ' ') %>% str_replace_all('and', '&') %>%  str_to_title()  

missing_winnings = setdiff(usage_chars, winning_chars)
for (char in missing_winnings) {
  try({
    text = read_html(paste0('https://ssbworld.com/characters/', char)) %>%
      html_nodes('.player-stat') %>% html_text() %>% 
      str_subset('-') %>%  str_extract('(?!.*:).+') %>% .[[1]]
    winning = c(winning, setNames(text, names(usage)[which(usage_chars == char)]))
  })
  
}
