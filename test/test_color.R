dimension    <- dim(photo)
photo_rgb <- data.frame(
  x = rep(1:dimension[2], each = dimension[1]),
  y = rep(dimension[1]:1, dimension[2]),
  R = as.vector(photo[,,1]), #slicing our array into three
  G = as.vector(photo[,,2]),
  B = as.vector(photo[,,3])
)
photo_kmeans= kmeans(photo_rgb[,c("R","G","B")], centers = 20, iter.max = 30)
photo_kmeans= kmeans(photo_rgb[,c("R","G","B")], centers = 2, iter.max = 30)

scales::show_col(rgb(photo_kmeans$centers))

centres <- list()
not_rgb =  c("120px-MrGame%26WatchHeadSSBUWebsite.png", "24px-SSBU_Icon.png")
for (pic in setdiff(list.files('pics/'), not_rgb)) {
  photo <- png::readPNG(paste0('pics/', pic))
  
  
  nz_inds = unlist(sapply(1:nrow(photo[,,]), function(x) {
    row =  photo[x,,1] + photo[x,,2] + photo[x,,3];
    tryCatch(min(which(row!=0)):max(which(row!=0)), error = function(e) {NULL}) + (x-1)*ncol(photo)
  }))
  
  photo_rgb <- data.frame(
    R = as.vector(photo[,,1])[nz_inds], 
    G = as.vector(photo[,,2])[nz_inds],
    B = as.vector(photo[,,3])[nz_inds]
  )
  photo_kmeans= kmeans(photo_rgb[,c("R","G","B")], centers = 1, iter.max = 30)
  centres[[pic]] <- photo_kmeans$centers
}

main_col = centres %>% 
  lapply(function(x) tibble::enframe(x[which.max(rowSums(x)), ], name = 'col')) %>% 
  bind_rows(.id = 'pic') %>% 
  tidyr::spread(key = 'col', value = 'value')

scales::show_col(rgb(main_col[stringr::str_detect(main_col$pic, 'Corrin'), c('R', 'G', 'B')]))
scales::show_col(rgb(main_col[stringr::str_detect(main_col$pic, 'BowserJ'), c('R', 'G', 'B')]))
scales::show_col(rgb(main_col[stringr::str_detect(main_col$pic, 'BowserH'), c('R', 'G', 'B')]))
scales::show_col(rgb(main_col[stringr::str_detect(main_col$pic, 'Yoshi'), c('R', 'G', 'B')]))
scales::show_col(rgb(main_col[stringr::str_detect(main_col$pic, 'Luigi'), c('R', 'G', 'B')]))
scales::show_col(rgb(main_col[stringr::str_detect(main_col$pic, '-Mario'), c('R', 'G', 'B')]))
scales::show_col(rgb(main_col[stringr::str_detect(main_col$pic, 'rMario'), c('R', 'G', 'B')]))
scales::show_col(rgb(main_col[stringr::str_detect(main_col$pic, 'Lucina'), c('R', 'G', 'B')]))
scales::show_col(rgb(main_col[stringr::str_detect(main_col$pic, 'Bayonetta'), c('R', 'G', 'B')]))
scales::show_col(rgb(main_col[stringr::str_detect(main_col$pic, 'Pac'), c('R', 'G', 'B')]))
scales::show_col(rgb(main_col[stringr::str_detect(main_col$pic, 'Lucas'), c('R', 'G', 'B')]))
scales::show_col(rgb(main_col[stringr::str_detect(main_col$pic, 'Mega'), c('R', 'G', 'B')]))


centres <- list()
not_rgb =  "120px-MrGame%26WatchHeadSSBUWebsite.png"
for (pic in setdiff(list.files('pics/'), not_rgb)) {
  photo <- png::readPNG(paste0('pics/', pic))
  photo_rgb <- data.frame(
    R = as.vector(photo[,,1]), 
    G = as.vector(photo[,,2]),
    B = as.vector(photo[,,3])
  )
  photo_kmeans= kmeans(photo_rgb[,c("R","G","B")], centers = 3, iter.max = 30)
  centres[[pic]] <- photo_kmeans$centers
}

top_three_cols = centres %>% 
  lapply(function(x) tibble::enframe(x[which.max(rowSums(x)), ], name = 'col')) %>% 
  bind_rows(.id = 'pic') %>% 
  tidyr::spread(key = 'col', value = 'value')
scales::show_col(rgb(top_three_cols[stringr::str_detect(top_three_cols$pic, 'Bayonetta'), c('R', 'G', 'B')]))
scales::show_col(rgb(top_three_cols[stringr::str_detect(top_three_cols$pic, 'Luigi'), c('R', 'G', 'B')]))
scales::show_col(rgb(top_three_cols[stringr::str_detect(top_three_cols$pic, 'Wario'), c('R', 'G', 'B')]))
