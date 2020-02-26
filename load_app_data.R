source('data_constants.R')
#char_colors <- readxl::read_excel('data/smash_colors.xlsx', sheet = 'Characters')

char_stats = readRDS('data/char_stats.rds')
incomplete_cols =  c('crawl', 'jumpsquat', 'gravity', 'tether', 'wall_cling', 'wall_jump', 'hard_landing_lag', 'fh_air_time', 'max_jumps', 'sh_air_time', 'soft_landing_lag')
all_plot_vars = setdiff(setdiff(colnames(char_stats), incomplete_cols), c('character', 'color', 'series_color', 'icon_path',  'icon_url_path'))

number_of_rows_dt = 10

if (anyNA(filter(char_stats, !is.na(tier) & !character %in% c('Byleth', 'Pokemon Trainer')))) stop('Unexpected missing values in char_list')

tier_stats = char_stats %>%
  select(all_plot_vars) %>% 
  filter(!is.na(tier)) %>% 
  group_by(tier) %>% 
  summarise_all(.funs = list(mean = ~ mean(x = ., na.rm = TRUE),
                             sd = ~ sd(x = ., na.rm = TRUE)))



#hchart(tier_stats, hcaes(y = usage_mean, x = tier), type = 'scatter') %>% hc_add_series(data = mutate(tier_stats, high = usage_mean + usage_sd, low = usage_mean - usage_sd), type = "errorbar",color = "red", stemWidth = 1,  whiskerLength = 1)



# ### GRAVEYARD ### #
# js_searchbox = "function() {
#             var chart = this,
#             points = chart.series[0].points,
#             searchInput = document.getElementById('input');
#             
#             function changeMatches() {
#               points.forEach(function(point) {
#                 point.update({
#                   color: null
#                 })
#                 if (point.name === searchInput.value) {
#                   
#                   point.update({
#                     color: 'red'
#                   })
#                   chart.tooltip.refresh(point)
#                 }
#               })
#             }
#             
#             searchInput.addEventListener('keyup', changeMatches);
# }"
# 
# 
# jscode <- "shinyjs.init = function() {
# 
# var signaturePad = new SignaturePad(document.getElementById('signature-pad'), {
#   backgroundColor: 'rgba(255, 255, 255, 0)',
#   penColor: 'rgb(0, 0, 0)'
# });
# var saveButton = document.getElementById('save');
# var cancelButton = document.getElementById('clear');
# 
# saveButton.addEventListener('click', function (event) {
#   var data = signaturePad.toDataURL('image/png');
# 
# // Send data to server instead...
#   window.open(data);
# });
# 
# cancelButton.addEventListener('click', function (event) {
#   signaturePad.clear();
# });
# 
# }"