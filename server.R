# Server functions
server <- function(input, output, session) {
  ## SIDEBAR
  observeEvent(input$use_tiers_data, {
    toggle('tier_color_scheme')
  })
  
  # Prevent duplicate names
  observeEvent(input$yvar_input, {
    updateSelectInput(session, 'xvar_input', choices = setdiff(all_plot_vars, c('tier', input$yvar_input)),selected = input$xvar_input)
  })
  observeEvent(input$xvar_input, {
    updateSelectInput(session, 'yvar_input', choices = setdiff(all_plot_vars, c('tier', input$xvar_input)), selected = input$yvar_input)
  })
  
  ## DATA
  reactive_dataset <- reactive({
    if(input$use_tiers_data){
      tier_stats %>% 
        select(name = tier, yvar = !!paste0(input$yvar_input, '_mean'), yvar_sd = !!paste0(input$yvar_input, '_sd'),
               xvar = !!paste0(input$xvar_input, '_mean'), xvar_sd = !!paste0(input$xvar_input, '_sd')) %>% 
        arrange(name) %>% 
        mutate(color = if(input$tier_color_scheme) {tier_cols_dg} else {tier_cols_bg}, image = tier_images) %>%
        do(., if(input$img_markers) {mutate(., marker = purrr::map(image, ~ list(symbol = sprintf("url(%s)", .x), width = 32, height = 32)))} else {.}) 
      
    } else {
      char_stats %>%
        select(name = character, id, image = icon_url_path, roster_image, color, xvar = input$xvar_input, yvar = input$yvar_input) %>%  
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
    input$yvar_input
    input$xvar_input
    if (!input$use_tiers_data) paste('Omitted:', str_flatten(setdiff(char_list$app_names, reactive_dataset()$name), ', '))
  })
  
  main_hc <- reactive({
    hchart(reactive_dataset(), type = 'scatter',
           hcaes(y = yvar, x = xvar, color = color, name = name, image =  image)) %>% 
      hc_legend(enabled = FALSE) %>%
      hc_chart(zoomType = 'xy') %>%
      hc_xAxis(title = list(text = input$xvar_input), minRange = diff(range(reactive_dataset()$xvar)/50)) %>%
      hc_yAxis(title = list(text = input$yvar_input), minRange = diff(range(reactive_dataset()$yvar)/50)) %>%
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
    #browser()
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
  observeEvent(list(input$main_dt_row_last_clicked,
                    input$roster_dt_cell_clicked,
                    input$main_plot_clicked,
                    input$use_roster_dt), {
                      browser()
                      if (input$use_roster_dt & (!is.null(input$roster_dt_cell_clicked$row) | input$main_plot_clicked)) {
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
                      } else {
                        dt_click_val(input$main_dt_row_last_clicked)
                      }
                      # row = (input$roster_dt_cells_selected[1])*12
                      #       col = ifelse(input$roster_dt_cells_selected[1] != floor(num_chars/12), input$main_dt_cells_selected[2] + 1,  input$main_dt_cells_selected[2] + 1 - ceiling((12 - num_chars %% 12) / 2) )
                    }) #, ignoreInit = TRUE, ignoreNULL = TRUE)
  ## DATA TABLE
  output$main_dt <- renderDataTable({
    datatable(reactive_dataset() %>% select(name, !!input$xvar_input := 'xvar', !!input$yvar_input := 'yvar'),
              callback = JS(""),selection = "single", rownames = FALSE, options = list(dom = 'tfp'))
  }, server = TRUE)
  
  tableProxy <-  dataTableProxy("main_dt")
  
  black_boxes = reactiveVal(0)
  
  output$roster_dt <- renderDataTable({
    roster_images = arrange(reactive_dataset(), id)$roster_image
    rem = length(roster_images) %% 12
    padded_images = c(roster_images[1:(length(roster_images)-rem)], rep('data/black_square.png', ceiling((12-rem)/2)), roster_images[(length(roster_images)-rem+1):length(roster_images)],  rep('data/black_square.png', floor((12-rem)/2)))
    images = sapply(padded_images, img_uri)
    template = as.data.frame(matrix(images, ncol = 12, byrow = TRUE)) 
    
    col_len = 12
    #zones = 
    #browser() 
    colors = sprintf('rgb(%s, %s, %s)', floor(seq(207, 228, length.out = col_len)), floor(seq(211, 200, length.out = col_len)), floor(seq(243, 65, length.out = col_len)))
    # sapply(1:length(padded_images), function(x) sapply(1:length(padded_images), function(x) 
    black_boxes({if(rem > 0) c(1:ceiling((col_len-rem)/2), if(rem < col_len-1) ((col_len+1-floor((col_len-rem)/2)):col_len)) else {0}})
    
    datatable(template, selection = list(mode = 'none'),##, target = 'cell'), 
              extensions = "Select", 
              #callback = JS(callback2(length(padded_images)/12, black_boxes, colors)),
              rownames = FALSE, colnames = rep("", 12), escape = FALSE, 
              callback = JS(select_callback),
              options = list(dom = 't', ordering = FALSE, select = list(items = 'cell', style ='single', selector = "td:not(.notselectable)"),
                             rowCallback = JS(callback(length(padded_images)/12, black_boxes(), colors)))
    )%>% 
      formatStyle(c(1:dim(template)[2]), border = '3px solid #000') #%>% 
  })
  
  rostertableProxy <-  dataTableProxy("roster_dt")
  
  observeEvent(input$main_plot_click, {
    #browser()
    if (input$main_plot_click$series == 'Series 1') {
      charId = which(arrange(reactive_dataset(), id)$name == input$main_plot_click$name)
      row = floor(charId/12) 
      # add black padding if final row
      col = ifelse(row != floor(nrow(reactive_dataset()) / 12), (charId-1)%%12, (charId-1)%%12 + ceiling((12 - (nrow(reactive_dataset()) %% 12)) / 2))
      
      rostertableProxy %>%
        #selectRows(NULL) %>%
        #selectCells(NULL) %>% 
        selectCells(matrix(c(row, col), ncol = 2))
      
      charId_main = which(reactive_dataset()$name == input$main_plot_click$name)
      
      tableProxy %>% 
        #selectRows(NULL) %>%
        #selectCells(NULL) %>% 
        selectRows(charId_main) %>%
        selectPage( (charId_main-1) %/% number_of_rows_dt + 1)
      
    } else {
      tableProxy %>%
        selectRows(NULL)
      
      rostertableProxy %>%
        selectCells(NULL)
    }
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
  
  
  observeEvent({dt_click_val()}, {
     
    if (!input$use_tiers_data & !is.null(dt_click_val())) {
        #((input$use_roster_dt & !is.null(input$roster_dt_cell_clicked$row)) | (!input$use_roster_dt & !is.null(input$main_dt_rows_selected))
        if (!input$use_roster_dt) {
          sound_row = char_list[char_list$app_names == reactive_dataset()[input$main_dt_rows_selected,]$name,]
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
  
  observeEvent(input$keyseq,{
    # Add to all keys
    all_keys(paste0(all_keys(), chr(input$keyseq))[1:min(length(all_keys()), 100)])
    
    last_key = tolower(chr(input$keyseq))
    # Change octave if it was a number
    if (last_key %in% as.character(3:5)) {
      octave(last_key)
    }
    # Play last key if it was a note
    if (last_key %in% letters[1:7]) {
      insertUI(selector = "#playsound",
               where = "afterEnd",
               ui = tags$audio(src = paste0("audio/easter/", last_key, octave(), ".mp3"), type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
      )
    }
  })
  
  
  observeEvent(input$hide_me, {
    #browser()
    isolate({
      if (str_detect(tolower(all_keys()), 'defdf4?5?cbab3?4?g4?5?a#a3?4?gfg4?5?a3?4?gfgedefdf4?5?cbabda#a3?4?gfg4?5?a3?4?gfgeg4?5?cd')) {
        insertUI(selector = "#playsound",
                 where = "afterEnd",
                 ui = tags$audio(src = "audio/easter/full_ult_riff.mp3", type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
        )
      } else if (str_detect(tolower(all_keys()), 'agababcdcbgefgagecd')) {
        insertUI(selector = "#playsound",
                 where = "afterEnd",
                 ui = tags$audio(src = "audio/easter/full_riff.mp3", type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
        )
      } else if (str_detect(tolower(all_keys()), 'defdf4?5?cbab3?4?g')) {
        insertUI(selector = "#playsound",
                 where = "afterEnd",
                 ui = tags$audio(src = "audio/easter/ult_riff.mp3", type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
        )
      }
    })
  })
  
}





