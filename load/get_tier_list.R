# Source: https://twitter.com/Jaaahsh/status/1229812803852173313
tryCatch(
  tier_list <- readxl::read_excel('data/pgr_tier_list_7.0.0.xlsx') %>% 
    mutate(character = str_replace_all(character, mapped_names),
           tier_score = as.numeric(tier_score), tier_rank = as.numeric(tier_rank),
           tier = ordered(tier, rev(c('S', 'A', 'B', 'C', 'D', 'E')))),
  error = function(e) {print('No PGR tier list data!')}
)