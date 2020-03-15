# Server functions
server <- function(input, output, session) {
  ## SIDEBAR
  plot_yvar <- reactiveVal(NULL)
  plot_xvar <- reactiveVal(NULL)
  observeEvent(input$yvar_input, {
    plot_yvar(input$yvar_input)
  })
  observeEvent(input$xvar_input, {
    plot_xvar(input$xvar_input)
  })
  observeEvent(input$swap_xy, {
    temp <- plot_yvar()
    plot_yvar(plot_xvar())
    plot_xvar(temp)
  })
  
  observeEvent(input$use_tiers_data, {
    toggle('tier_color_scheme')
  })
  
  # Prevent duplicate names
  observeEvent(plot_yvar(), {
    updateSelectInput(session, 'xvar_input', choices = setdiff(all_plot_vars, c('tier', plot_yvar())),selected = plot_xvar())
  })
  observeEvent(plot_xvar(), {
    updateSelectInput(session, 'yvar_input', choices = setdiff(all_plot_vars, c('tier', plot_xvar())), selected = plot_yvar())
  })

  
  ## DATA
  reactive_dataset <- reactive({
    if(input$use_tiers_data){
      tier_stats %>% 
        select(name = tier, yvar = !!paste0(plot_yvar(), '_mean'), yvar_sd = !!paste0(plot_yvar(), '_sd'),
               xvar = !!paste0( plot_xvar(), '_mean'), xvar_sd = !!paste0(plot_xvar(), '_sd')) %>% 
        arrange(name) %>% 
        mutate(color = if(input$tier_color_scheme) {tier_cols_dg} else {tier_cols_bg}, image = tier_images) %>%
        do(., if(input$img_markers) {mutate(., marker = purrr::map(image, ~ list(symbol = sprintf("url(%s)", .x), width = 32, height = 32)))} else {.}) 
      
    } else {
      char_stats %>%
        select(name = character, id, image = icon_url_path, roster_image, color, xvar = plot_xvar(), yvar = plot_yvar()) %>%  
        #group := ifelse(input$use_tiers_data, !!'tier', one_of('you_get_nothing_you_lose'))) %>%
        filter_all(all_vars(!is.na(.))) %>%
        mutate(color = if(input$img_markers) {sapply(color, function(x) paste0('rgba(', str_flatten(as.vector(col2rgb(x)), ','), ',0.3)')) } else {toupper(color)}) %>%
        do(., if(input$img_markers) {mutate(., marker = purrr::map(image, ~ list(symbol = sprintf("url(%s)", .x), width = 32, height = 32)))} else {.}) %>% 
        arrange(name)
    }
    
    # color = purrr::map(color, ~paste0('rgba(', str_flatten(as.vector(col2rgb(.x)), ','), ',0.3)')))
  })
  
  ## PLOT
  output$omitted <- renderText({
    plot_yvar()
    plot_xvar()
   
    raw_text = if (!input$use_tiers_data) paste('Omitted:', str_flatten(setdiff(char_list$app_names, reactive_dataset()$name), ', '))
    
    #if (str_detect(raw_text, str_flatten(pokemon, ', ')) {
    #   if (str_detect(raw_text, 'Pokemon Trainer')) {
    #     browser()
    #     raw_text = paste0(str_extract(raw_text, '.*Pokemon Trainer'), ':{', str_flatten(pokemon, ', '), '}', str_split(raw_text, str_flatten(pokemon, ', '))[[1]][2])
    #   } else {
    #     browser()
    #   }
    # }
     raw_text
  })
  
  main_hc <- reactive({
    hchart(reactive_dataset(), type = 'scatter',
           hcaes(y = yvar, x = xvar, color = color, name = name, image =  image)) %>% 
      hc_legend(enabled = FALSE) %>%
      hc_chart(zoomType = 'xy') %>%
      hc_xAxis(title = list(text = plot_xvar()), minRange = diff(range(reactive_dataset()$xvar)/50)) %>%
      hc_yAxis(title = list(text = plot_yvar()), minRange = diff(range(reactive_dataset()$yvar)/50)) %>%
      hc_plotOptions(series = list(allowPointSelect= FALSE)) %>%
      hc_add_event_point(event = "click") %>%
      #hc_add_event_point(event = "unselect") %>%
      hc_tooltip(useHTML = TRUE,
                 formatter= JS("function() {return (this.point.name + '<span style=\"color: this.point.color\"></br>x: <b>' + this.point.x + '</b> </br> y: <b>' +
   this.point.y + '</b></span></br><img src=\"'+ this.point.image + '\"width=\"48\" height=\"48\"/></br>');}")) %>%
      hc_add_theme(hc_theme_chalk())
  })
  #observeEvent(input$foo, {print(input$foo)})
  
  output$main_plot <- renderHighchart({
    if (is.null(dt_click_val())| input$use_tiers_data) {
      #browser()
      highlighted_point = NULL
    } else if (!input$use_roster_dt) {
      #browser()
      highlighted_point = select(reactive_dataset()[dt_click_val(), ], x= xvar, y = yvar, color, name, image) 
    } else {   
      #browser()
      highlighted_point =  select(arrange(reactive_dataset(), id)[dt_click_val(),] , x= xvar, y = yvar, color, name, image) # ifelse(col > 0 & (row+col) < num_chars,NULL)
    }
    #browser()
    main_hc() %>% 
      hc_add_series(data = highlighted_point, type = 'scatter', marker = list(radius = 30, lineWidth = 5, lineColor = ifelse(input$img_markers, "rgba(32,205,32, 0.3)", 'rgba(32,205,32, 1)')))
    
  })
  
  dt_click_val <- reactiveVal(NULL)
  observeEvent(list(input$main_dt_rows_selected,
                    input$roster_dt_cells_selected,
                    input$use_roster_dt), {
                      #browser()
                      if (input$use_roster_dt) {
                        #browser()
                        if (nrow(input$roster_dt_cells_selected) == 0) {
                          dt_click_val(NULL)
                        } else if (length(input$roster_dt_cell_clicked) != 0) {
                          if (( input$roster_dt_cell_clicked$row== input$roster_dt_cells_selected[1]) &
                              ( input$roster_dt_cell_clicked$col== input$roster_dt_cells_selected[2])) {
                            #browser()
                            nchars = nrow(reactive_dataset())
                            row = input$roster_dt_cell_clicked$row
                            col = input$roster_dt_cell_clicked$col + 1
                            if (row != ceiling(nchars/12) ) {
                              dt_click_val((row-1)*12 + col) 
                            } else if (!col %in% black_boxes()) {
                              col = col - ceiling((12 - nchars %% 12) / 2) 
                              dt_click_val((row-1)*12 + col) 
                            } 
                          }
                        }
                      } else {
                        if (!is.null(input$main_dt_rows_selected)) {
                          dt_click_val(input$main_dt_rows_selected)
                        } else {
                          dt_click_val(NULL)
                        }
                      }
                    }, ignoreInit = TRUE)#, ignoreNULL = TRUE)
  
  observeEvent(input$main_plot_click, {
    if (input$main_plot_click$series == 'Series 1') {
      if (input$use_roster_dt) {
        charId = which(arrange(reactive_dataset(), id)$name == input$main_plot_click$name)
        #browser()
        row = ceiling(charId/12) 
        col = (charId-1)%%12
        dt_click_val((row-1)*12+(col+1))
      } else {
        charId_main = which(reactive_dataset()$name == input$main_plot_click$name)
        dt_click_val(charId_main)
      }
    } else {
      dt_click_val(NULL)
    }
  })                      
  
  ## DATA TABLE
  output$main_dt <- renderDataTable({
    datatable(reactive_dataset() %>% select(name, !!plot_xvar() := 'xvar', !!plot_yvar() := 'yvar'),
              selection = "single", rownames = FALSE, options = list(dom = 'tfp'))
  }, server = TRUE)
  
  tableProxy <-  dataTableProxy("main_dt")
  
  black_boxes = reactiveVal(0)
  
  output$roster_dt <- renderDataTable({
    roster_images = arrange(reactive_dataset(), id)$roster_image
    rem = length(roster_images) %% 12
    padded_images = c(roster_images[1:(length(roster_images)-rem)], rep('data/black_square.png', ceiling((12-rem)/2)), roster_images[(length(roster_images)-rem+1):length(roster_images)],  rep('data/black_square.png', floor((12-rem)/2)))
    images = sapply(padded_images, img_uri())
    template = as.data.frame(matrix(images, ncol = 12, byrow = TRUE)) 
    
    col_len = 12
    #zones = 
    #browser() 
    colors = sprintf('rgb(%s, %s, %s)', floor(seq(207, 228, length.out = col_len)), floor(seq(211, 200, length.out = col_len)), floor(seq(243, 65, length.out = col_len)))
    # sapply(1:length(padded_images), function(x) sapply(1:length(padded_images), function(x) 
    black_boxes({if(rem > 0) c(1:ceiling((col_len-rem)/2), if(rem < col_len-1) ((col_len+1-floor((col_len-rem)/2)):col_len)) else {0}})
    template$final_row = c(rep(0, nrow(template)-1), 1)
    #browser()
    output_dt <- datatable(template, selection = list(mode = 'single', target = 'cell'), 
                           # = "Select", 
                           #callback = JS(callback2(length(padded_images)/12, black_boxes, colors)),
                           rownames = FALSE, colnames = rep("", ncol(template)), 
                           escape = FALSE, 
                           #callback = JS(select_callback),
                           options = list(dom = 't', ordering = FALSE#, select = list(items = 'cell', style ='single')
                                          ,columnDefs = list(list(visible=FALSE, targets = ncol(template)-1))
                                        
                           #, selector = "td:not(.notselectable)"),
                           #,rowCallback = JS(callback3())
                           )
    )%>% 
      formatStyle(c(1:dim(template)[2]-1), border = '3px solid #000')  %>% 
      formatStyle(columns = black_boxes(), valueColumns = 'final_row',  #target = 'cell',#`pointer-events`= "none", cursor = "default")
                  #backgroundColor = styleEqual(c(0, 1), c('gray', 'yellow')),
                  `pointer-events`= styleEqual(c(0,1), c("auto" , "none"))) #`pointer-events`=
                  #cursor= styleEqual(c(0,1), c('auto', "default"))) # cursor= "default"#
    
    
    output_dt
  })
  
  rostertableProxy <-  dataTableProxy("roster_dt")
  
  observeEvent(input$main_plot_click, {
    #browser()
    if (input$main_plot_click$series == 'Series 1') {
      if (input$use_roster_dt) {
        charId = which(arrange(reactive_dataset(), id)$name == input$main_plot_click$name)
        row = ceiling(charId/12) 
        # add black padding if final row
        col = ifelse(row != ceiling(nrow(reactive_dataset()) / 12), (charId-1)%%12, (charId-1)%%12 + ceiling((12 - (nrow(reactive_dataset()) %% 12)) / 2))
        
        rostertableProxy %>%
          selectCells(matrix(c(row, col), ncol = 2))
      } else {
        tableProxy %>% 
          #selectRows(NULL) %>%
          #selectCells(NULL) %>% 
          selectRows(dt_click_val()) %>%
          selectPage( (dt_click_val()-1) %/% number_of_rows_dt + 1)
      }
    } else {
      tableProxy %>%
        selectRows(NULL)
      
      rostertableProxy %>%
        selectCells(NULL)
    }
  })
  
  pos <- 0L:11L
  nextColor <- function() {
    # Choose the next color, wrapping around to the start if necessary
    pos <<- (pos %% length(colors)) + 1L
    colors[pos]
  }
  
  observe({
    # Send the next color to the browser
    session$sendCustomMessage("background-color", 
                              list(row = 0:floor(nrow(reactive_dataset())/12),
                                   col = 0:11,
                                   value = nextColor()))
    
    # Update the color every 100 milliseconds
    invalidateLater(100)
  })
  
  
  # id_row = eventReactive( input$roster_dt_cells_selected, {
  #   isolate({
  #     if (!is.null(input$main_dt_cells_selected)) {
  #       num_chars =  nrow(reactive_dataset())
  #       row = (input$roster_dt_cells_selected[1])*12
  #       col = ifelse(input$roster_dt_cells_selected[1] != floor(num_chars/12), input$main_dt_cells_selected[2] + 1,  input$main_dt_cells_selected[2] + 1 - ceiling((12 - num_chars %% 12) / 2) )
  #       row+col
  #     } else {
  #       NULL
  #     }
  #   })
  # })
  
  ## SOUND
  observeEvent(input$playsound, {
    if (input$playsound) {
      insertUI(selector = "#playsound",
               where = "afterEnd",
               ui = tags$audio(src = "audio/easter/lalalalalalaaa.mp3", type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
      ) 
    } else {
      insertUI(selector = "#playsound",
               where = "afterEnd",
               ui = tags$audio(src = "audio/easter/hahaha.mp3", type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
      )
    }
    
  }, ignoreInit = TRUE)
  
  # observeEvent(input$hidden_button, {
  #   insertUI(selector = "#hidden_button",
  #            where = "afterEnd",
  #            ui = tags$audio(src = paste0('audio/announcer/melee/', melee_bonuses['READY']), type = 'audio/wav', autoplay = TRUE, controls = NA, style="display:none;")
  #   )
  #   
  #   insertUI(selector = "#hidden_button",
  #            where = "afterEnd",
  #            ui = tags$audio(src = paste0('audio/announcer/melee/', melee_bonuses['GO']), type = 'audio/wav', autoplay = TRUE, controls = NA, style="display:none;")
  #   )
  # }, ignoreNULL = FALSE)
  height = reactiveVal(28)
  width = reactiveVal(50)
  observeEvent(input$dimension, {
    width(input$dimension[1] / 25)
    height(input$dimension[2] / 25)
  })
  
  img_uri <- reactiveVal(
    function(x) sprintf(paste0('<img src="%s" height =', height(),'px width = ', width(),'px"/>'), knitr::image_uri(x)) 
  )
  
  observeEvent({dt_click_val()}, {
    
    if (!input$use_tiers_data & !is.null(dt_click_val())) {
      #((input$use_roster_dt & !is.null(input$roster_dt_cell_clicked$row)) | (!input$use_roster_dt & !is.null(input$main_dt_rows_selected))
      if (!input$use_roster_dt) {
        sound_row = char_list[char_list$app_names == reactive_dataset()[dt_click_val(),]$name,]
      } else {
        #browser() 
        sound_row = char_list[char_list$app_names == arrange(reactive_dataset(), id)[dt_click_val(),]$name, ]
      } 
      available_sounds = select_if(sound_row[, input$enabled_sounds, drop = FALSE], function(x) x!="")
      
      if (ncol(available_sounds) > 0) {
        sound_clip = paste(str_remove(colnames(available_sounds[1]), '_sounds'), available_sounds[,1], sep = '/')
        if (length(sound_clip) == 1) {
          insertUI(selector = "#playsound",
                   where = "afterEnd",
                   ui = tags$audio(src = paste0('audio/announcer/', sound_clip), type = paste0("audio/", str_extract(sound_clip, '\\..+$')), 
                                   autoplay = NA, controls = NA, style="display:none;"))
        }
      }
    }
  }, ignoreInit = TRUE)
  
  ## EASTER
  all_keys <- reactiveVal("")
  octave <- reactiveVal('4')
  
  output$last_key = renderText({
    chr(input$keyseq)
  })
  
  hash_before <- reactiveVal(FALSE)
  
  observeEvent(input$keyseq,{
    # Add to all keys
    all_keys(tail(paste0(all_keys(), chr(input$keyseq)), 100))
    
    last_key = tolower(chr(input$keyseq))
    
    if (last_key %in% letters[1:7]) {
      # Play last key if it was a note
      insertUI(selector = "#playsound",
               where = "afterEnd",
               ui = tags$audio(src = paste0("audio/easter/", last_key, ifelse(hash_before(), '-', ''), octave(), ".mp3"), type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
      )
      hash_before(FALSE)
    } else if (last_key %in% as.character(3:5)) { 
      # Change octave if it was a number
      octave(last_key)
    } else {
      hash_before(FALSE)
    }

    if (last_key == "#") {
      # Set for sharp note
      hash_before(TRUE)
    }
  })
  
  
  observeEvent(input$hide_me, {
    #browser()
    isolate({
      if (str_detect(tolower(all_keys()), 'defdf4?5?cbab3?4?g4?5?#a.{1}a3?4?gfg4?5?a3?4?gfgedefdf4?5?cbabd#a.{1}a3?4?gfg4?5?a3?4?gfgeg4?5?cd')) {
        insertUI(selector = "#playsound",
                 where = "afterEnd",
                 ui = tags$audio(src = "audio/easter/full_ult_riff.mp3", type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
        )
      } else if (str_detect(tolower(all_keys()), 'defdf4?5?cbab3?4?g')) {
        insertUI(selector = "#playsound",
                 where = "afterEnd",
                 ui = tags$audio(src = "audio/easter/ult_riff.mp3", type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
        )
      } else if (str_detect(tolower(all_keys()), 'b(3#)|(#3)f4b#fb#f5a(4#)|(#4)geb.{1}b#cdbd#fe')) {
         
        insertUI(selector = "#playsound",
                 where = "afterEnd",
                 ui = tags$audio(src = "audio/easter/melee_riff.mp3", type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
        )
      }
    })
  })
  
}





