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
        select(name = character, image = icon_url_path, color, xvar = input$xvar_input, yvar = input$yvar_input) %>%  
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
                 formatter= JS("function() {return (this.point.name + '<span style=\"color: this.point.color\"></br>y: <b>' + this.point.y + '</b> </br> x: <b>' +
   this.point.x + '</b></span></br><img src=\"'+ this.point.image + '\"width=\"48\" height=\"48\"/></br>');}")) %>%
      hc_add_theme(hc_theme_chalk())
  })
  
  output$main_plot <- renderHighchart({
    #browser()
    #str_flatten(as.vector(col2rgb(reactive_dataset()$color)), ','), ',0.3)')
    main_hc() %>% 
      hc_add_series(data = if (is.null(input$main_datatable_rows_selected) | input$use_tiers_data) {NULL}
                    else {select(reactive_dataset()[input$main_datatable_rows_selected, ], x= xvar, y = yvar, color, name, image)},
                    type = 'scatter', marker = list(radius = 30, lineWidth = 5, lineColor = ifelse(input$img_markers, "rgba(32,205,32, 0.3)", 'rgba(32,205,32, 1)')
                    ))
  })
  
  ## DATA TABLE
  output$main_datatable <- renderDataTable({
    datatable(reactive_dataset() %>% select(name, !!input$xvar_input := 'xvar', !!input$yvar_input := 'yvar'), selection = "single", rownames = FALSE, options = list(dom = 'tf'))
  }, server = TRUE)
  
  tableProxy <-  dataTableProxy("main_datatable")
  
  observeEvent(input$main_plot_click, {
    if (input$main_plot_click$series == 'Series 1') {
      charId = which(reactive_dataset()$name == input$main_plot_click$name)
      
      tableProxy %>% 
        selectRows(charId) %>%
        selectPage( (charId-1) %/% number_of_rows_dt + 1)
      
      
    } else {
      #browser()
      tableProxy %>%
        selectRows('')
    }
  })
  
  ## SOUND
  observeEvent(input$playsound, {
    if (input$playsound) {
      insertUI(selector = "#playsound",
               where = "afterEnd",
               ui = tags$audio(src = "audio/lalalalalalaaa.mp3", type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
      ) 
    } else {
      insertUI(selector = "#playsound",
               where = "afterEnd",
               ui = tags$audio(src = "audio/hahaha.mp3", type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
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
  
  
  observeEvent(input$main_datatable_rows_selected, {
    if (!input$use_tiers_data){
      sound_row = char_list[char_list$app_names == reactive_dataset()[input$main_datatable_rows_selected,]$name,]
      available_sounds = select_if(sound_row[, input$enabled_sounds, drop = FALSE], function(x) x!="")
      #browser()
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
  })
  
  ## EASTER
  all_keys <- reactiveVal("")
  
  output$last_key = renderText({
    chr(input$keyseq)
  })
  
  observeEvent(input$keyseq,{
    all_keys(paste0(all_keys(), chr(input$keyseq))[1:min(length(all_keys()), 100)])
  })
  
  
  observeEvent(input$hide_me, {
    #browser()
    isolate({
    if (str_detect(tolower(all_keys()), 'defdfcbabga#agfgagfgedefdfcbabda#agfgagfgegcd')) {
      insertUI(selector = "#playsound",
               where = "afterEnd",
               ui = tags$audio(src = "audio/easter/full_riff.mp3", type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
      )
    } else if (str_detect(tolower(all_keys()), 'defdfcbabg')) {
      insertUI(selector = "#playsound",
               where = "afterEnd",
               ui = tags$audio(src = "audio/easter/riff.mp3", type = "audio/mp3", autoplay = NA, controls = NA, style="display:none;")
      )
    }
  })
  })
  
}





