source('data_constants.R')
#char_colors <- readxl::read_excel('data/dont_commit/smash_colors.xlsx', sheet = 'Characters')

char_stats = readRDS('data/dont_commit/char_stats.rds')
incomplete_cols =  c('crawl', 'jumpsquat', 'gravity', 'tether', 'wall_cling', 'wall_jump', 'hard_landing_lag', 'fh_air_time', 'max_jumps', 'sh_air_time', 'soft_landing_lag')
all_plot_vars = setdiff(setdiff(colnames(char_stats), incomplete_cols), c('character', 'id', 'color', 'series_color', 'icon_path',  'icon_url_path', 'roster_image'))
img_uri <- function(x) { sprintf('<img src="%s" height = 28px width = 50px"/>', knitr::image_uri(x)) }

changeCellColor <- function(){
  #row = ceiling(ind/12)
  #col = ifelse(ind %% 12 == 0, 12, ind %% 12)
  #   c(
  #     "function(row, data, num, index){",
  #     sprintf("  if(index == %d){", row-1),
  #     sprintf("    $('td:eq(' + %d + ')', row)", col-1),
  #     "    .css({'background-color': 'orange'});",
  #     "  }",
  #     "}"  
  #   )
  # }
  
  c(
    "function(row, data, num, index){",
    sprintf("    $('td:eq(' + %d + ')', row).css({'background-color': 'orange'})", 1:12),
    "}"  
  )
}


callback <- function(last_row, cols, colors){
  c(
    "function(row, data, num, index){",
    sprintf("if(index == %d){", last_row-1),
    sprintf("    $('td:eq(' + %d + ')', row).addClass('notselectable');", cols-1),
    #sprintf("    $('td:eq(' + %d + ')', row).css({'background-color': ' + %s + ');", 0:(length(colors)-1), colors),
    "  }",
    #"$(row).addClass('notselectable')",
    "}"
  )
}

callback2 <- function(last_row, cols, colors){
  c(
    "table.on('click', 'td', function() {",
    sprintf("if(index == %d){", last_row-1),
    sprintf("    $('td:eq(' + %d + ')', row).removeClass('selected');", cols-1),
    #sprintf("    $('td:eq(' + %d + ')', row).css({'background-color': ' + %s + ');", 0:(length(colors)-1), colors),
    "  }",
    #"$(row).addClass('notselectable')",
    "}"
  )
}

# click_callback <- c(
#   c(
#  # "var id = $(main_datatable.table().node()).closest('.datatables').attr('id');",
#   "table.on('click', 'tbody', function(){",
#   "  setTimeout(function(){",
#   "    var indexes = table.cells({selected:true}).indexes();",
#   "    Shiny.setInputValue('main_datatable_cells_selected', indexes);",
#   "  }, 0);",
#   "});"
# )


number_of_rows_dt = 10

#207 211 243
#228 200 65
#249 245 183
# TIER STUFF
if (anyNA(filter(select(char_stats, character, all_plot_vars, -initial_dash), !is.na(tier) & !character %in% c('Byleth', 'Pokemon Trainer')))) stop('Unexpected missing values in char_list')
tier_cols_dg = c("#6B4804","#7F5515", '#907554' , "#CD7F32", "#C0C0C0", "#FFD700") # poop brown
tier_cols_bg = RColorBrewer::brewer.pal('Spectral',n=6)

#tier_images = c('https://i.redd.it/evp0pg3dmhg31.jpg', 'https://steamuserimages-a.akamaihd.net/ugc/921420320507613852/BA5F18024E735461C5131382A8D3E19D93A100A9/?imw=1024&imh=576&ima=fit&impolicy=Letterbox&imcolor=%23000000&letterbox=true',
#                'https://www.grandforksherald.com/incoming/article1187449.ece/alternates/BASE_LANDSCAPE/Kernel%20Cobb%20at%20Concordia','https://i.ytimg.com/vi/8HSy1ct1QhI/maxresdefault.jpg', 'https://mat3e.github.io/brains/img/6.jpg',
#                'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxITEhMTEhIWFRUXGB0YFxgYFxoXGhsfGhUWGBgYGBcYHSggHRolHRoYITEiJSkrLi4uGh8zODMsNygtLisBCgoKDg0OGxAQGy4lICYyLS4vLS0tLS4vLS0vLS0tLy0tLS0tLS0tLS0tLS01LS0tLS0tLS0tLS0tLS0tLS0tLf/AABEIAHAAcAMBIgACEQEDEQH/xAAbAAADAQEBAQEAAAAAAAAAAAAEBQYDBwIBAP/EADYQAAEDAwIDBgUCBQUAAAAAAAEAAhEDBCEFMRJBUQYTYXGh8CKBkbHhwdEUFjJCUgcVIySC/8QAGgEAAgMBAQAAAAAAAAAAAAAAAwQBAgUGAP/EACYRAAICAgIBBAEFAAAAAAAAAAECAAMRIRIxBBMyQVEFFCIzccH/2gAMAwEAAhEDEQA/AOJrezpkvELFU3Y3TO8cTwy6Q1g8TzTXi1Gy0CXUZMqew3ZoXFbvKgmlSgu6Odu1vlzP5VzqlbjeMzG3QJIdWpWdLuA8CBk8y6fiPvok/wDONNx8Vo+VaK1J+fiNUoOYLSu7vbC9PYf3U/a6/wARHCZTqrcksJG65hlPZmsrZ6m1OmMZyiWUh0XPdS7R1aVQ8OQOadaP2zY4APiTuh2VkDIgnuHUsaDWHkvtekG5QltcNeOJjgcJjSPEIKDELiUPPOoOA3/FKNXDWmA0QRt72TupQISzUmt4SXctv2wvQNbrz5dicz7RafuWtwpF9ItXQtSZxSSI+3lKkNRoiT1TdTfEpeAfbEDRldN7MP8A4S34mtmo5vw+BdGfpP1XOLBk1GDxC6LqDnNa0NEnhwOgIkk9OQXS/jK14O5/qerEAr6d3zi6q8knkEuuuz72ZZ8Q9Vox9Ynce/RM7bTqtQj4sdQFi+RY5sJEeCKR1MOzlu8VAOE5Oy6BVt+Gnvn8IHRdMFMD+53Uo+sTMOx4JPyX6WPUpgbnOtYt3STGSdkFQ0qq7LRCs+1FnLeNuDzUxRuKrMgSJ5Oz6q9T5WL2rhsGOtHvK1D+tsiOUlV+l62HCR8wcEKEp6410B4IPiIP12TG2qgniad+n6oDr8yvBWGO5duvZO8JNrhIzlerOrIB3I3W97Q4mlBi61hTgSG1K5kJJdNEHHJO9Vti0n6BIrqUwkXsXBxAuxWnOr3dJjROZPgBkkrpd5aNe52Izv5YGUk/0htQ3vazv8SB4xy+sfRUheN/mt61no8YAHGf9jXg1hm3BaGj0m5djqTlAv1+kxxp0yM+UkclprepDge0GCRhQP8At7i7inMz4pHx7Cq8vn7Ma8huJwonTaOtw3EYW1vq9K4Aa544xsR+FB0tOrVQWkhrTuZhCt0Kpb1Q+nUa4DJg58oSdtaFjvcn1TkftnTe6DmkHPVI7vRmzjbwW+h6iXhx6RPqmlMcZwlNoY5wVxuT1HQw7n9Qj7Xss4HiYfGOSpbeyAEuX03hYYgQp5mKWjH8fcAp2TqZ+IYWoCKubziEIJrlWLZYjLdyZ7U0sKNrPVl2wfsOqiah/KPX1FbmyZU9kavd2rBzcCT9T+y2v9R4djk4CwpM4KVNo5NH3OVM39241TB2wPBdB+SGXWv6AjNFnpJmH1ab6rjEnOSfvKZWWju3Lmjzn7pZSvXABjNwM/qtxfQDxV2iM5SltS4wsIhU7eN7iwrzLQC0dClFVz2kh4MeK+0e0/CP6gfmmFPVqVcFsiSPeVnsjLClUb2mNezVZjmlnCBPTcomwuOBxadwYU7Rmi7iGQt73URxNqA74d+hQCu4VLcLgytfdEmZO204XvjkGUot60iUTSqwqkSz4I1CC5fuLPJZly8F/VVMWYRP2qZMeSj6dGdhKp9brcczty8UPa1W0myQAd/LojKcCZ3Dnacz3XqwzriAp22tC574GZJ+f7JxUug7EQUJYZqYOJ/RdF+U3byEMmwBElZz6VR3GCJBAnzQVzVkq/uLWjVA71oJ5GUP/Ldo7qP/AEs++t6sBodaDYDxM5+StLerwkELoVHszZwZaT85WNx2UtXf0hzfIpY3KO5H6GwbBET6Rq8/A8yCI9F9uyWtLdwqKw7L24EcB8XE5S7XqDGEU2DAGUMurHUvZW4XLRrooJpNJOYRjayXWdfgpAdG4X63rzPjPyQiIUNgARw+uMZQ9zdjP0SqpemAOm/1/KEq3W8++Srxi9jzS6fJA977rPWX/wDY4f7YEjzCH0hr6tUNptLjMnoPM9FcUuzVMv7ypl0zjb8qWYL3E62CuWac/wC8GM52/PqERpQh0pTaXA2Ow9c4+/onMQ4fb3yXUWJ+orDL3Lo2DGF3Sfw/CEn/AIO4OQ0x1/CbVNTIbA2890O3VMj4kh5lnX2IwOMJ0/T7j/A+ifWtm8QHQAgLLVX7Sj6usNj06rFcsTG6+IHcJfVDQVHavVBqY6plfajGQd1MXNwXPznxVq1+YK+zWIa+7+E/QeqztLzDs7R9krrVowvtvVgFG46ivPcZCv4oa8uCAY3P64hCCpnde9P/AOSu0HYfEV7jjcgnOp0PsdbCjSaN3Oy49Tj0Ce3erU6TC4ieQzueg/dI6Nbu2QMFw36Dkfmkmv3XE4NGzcfPmf0+SzFVvIuwDqS4U6kKXQ6Uzp6sSCCcxv797pfXbuhC5dFRe9fti7aMb3F5IEH3ELFlxkZS41OS/cSpYeZzPCwx/R1GNyvrtT9UhD1+FTxS/piX9UxtX1DEISpXQbnnC/d4pCASpcmFl6+h0BDAr2XbKcT2Zsx+EToIJc90dAgJ+ElP9Gp8NIDmcn5+whvoS6bMrtWqNNchrscIAjIgAD9x81J3dUhx981oK/A5rczEYzA8UHfOkz0Q/Cr4ucySZ//Z')

tier_images = c(
  'https://static-cdn.jtvnw.net/emoticons/v1/300978616/3.0', #stinky
  'https://static-cdn.jtvnw.net/emoticons/v1/425618/1.0', #lul
  'https://static-cdn.jtvnw.net/emoticons/v1/300654653/1.0', #daHeck 
  'https://static-cdn.jtvnw.net/emoticons/v1/1431656/1.0', #expand
  'https://static-cdn.jtvnw.net/emoticons/v1/140967/1.0', # hbox
  ' https://static-cdn.jtvnw.net/emoticons/v1/300067189/1.0' #rip hboxKrey 'https://static-cdn.jtvnw.net/emoticons/v1/120195/1.0'
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