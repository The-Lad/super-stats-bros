source('data_constants.R')
#char_colors <- readxl::read_excel('data/dont_commit/smash_colors.xlsx', sheet = 'Characters')

char_stats = readRDS('data/dont_commit/char_stats.rds')
incomplete_cols =  c('crawl', 'jumpsquat', 'gravity', 'tether', 'wall_cling', 'wall_jump', 'hard_landing_lag', 'fh_air_time', 'max_jumps', 'sh_air_time', 'soft_landing_lag')
all_plot_vars = setdiff(setdiff(colnames(char_stats), incomplete_cols), c('character', 'id', 'color', 'series_color', 'icon_path',  'icon_url_path', 'roster_image'))
pokemon = c('Charizard', 'Squirtle', 'Ivysaur')
ice_climbers = c('Popo', 'Nana')

# DATA TABLES
colors <- sprintf('rgb(%s,%s,%s)', floor(seq(75, 230, length.out = 20)), floor(seq(0, 180, length.out = 20)), floor(seq(130, 230, length.out = 20)))
colors <- c(colors, rev(colors[c(-1, -20)])) # Mirror the colors to cycle back and forth smoothly
number_of_rows_dt = 10

# TIER STUFF
if (anyNA(filter(select(char_stats, character, all_plot_vars, -initial_dash), !is.na(tier) & !character %in% c('Byleth', 'Pokemon Trainer')))) stop('Unexpected missing values in char_list')
tier_cols_dg = c("#6B4804","#7F5515", '#907554' , "#CD7F32", "#C0C0C0", "#FFD700") # poop brown
tier_cols_bg = RColorBrewer::brewer.pal('Spectral',n=6)

tier_images = c(
  'https://static-cdn.jtvnw.net/emoticons/v1/300978616/3.0', #stinky
  'https://static-cdn.jtvnw.net/emoticons/v1/425618/1.0', #lul
  'https://static-cdn.jtvnw.net/emoticons/v1/300654653/1.0', #daHeck 
  'https://static-cdn.jtvnw.net/emoticons/v1/1431656/1.0', #expand
  'https://static-cdn.jtvnw.net/emoticons/v1/140967/1.0', # hbox
  'https://static-cdn.jtvnw.net/emoticons/v1/300067189/1.0' #rip hboxKrey 'https://static-cdn.jtvnw.net/emoticons/v1/120195/1.0'
)

tier_stats = char_stats %>%
  select(all_plot_vars) %>% 
  filter(!is.na(tier)) %>% 
  group_by(tier) %>% 
  summarise_all(.funs = list(mean = ~ mean(x = ., na.rm = TRUE),
                             sd = ~ sd(x = ., na.rm = TRUE))) %>% 
  mutate_if(is.numeric, round, 3)

chr <- function(n) { rawToChar(as.raw(n)) }

#hchart(tier_stats, hcaes(y = usage_mean, x = tier), type = 'scatter') %>% hc_add_series(data = mutate(tier_stats, high = usage_mean + usage_sd, low = usage_mean - usage_sd), type = "errorbar",color = "red", stemWidth = 1,  whiskerLength = 1)
