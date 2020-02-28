# UI functions
ui<- dashboardPage(
  #setBackgroundColor("#FFFFFF"),
  dashboardHeader(title = 'SUPER STATS BROS'),
  dashboardSidebar(
    selectInput('xvar_input', label = 'Choose x variable:',
                choices = setdiff(all_plot_vars, 'tier'),
                selected = 'air_speed'),
    selectInput('yvar_input', label = 'Choose y variable:',
                choices = setdiff(all_plot_vars, 'tier'),
                selected = 'fall_speed'),
    prettyCheckbox('img_markers', label = 'Images as markers?', shape = 'curve'),
    prettyCheckbox('use_tiers_data', label = "Group by tier?", shape = 'curve'),
    switchInput(
      inputId = "tier_color_scheme",
      onLabel = 'dumpster \nto glory',
      offLabel = 'boring',
      label = "<i class=\"fa fa-grin-hearts\"></i>"
    ),
    prettyCheckbox('playsound', label = 'click 4 a surprise'),
    prettyCheckboxGroup('enabled_sounds', label = 'Use which sounds? (Older preferred)', shape = 'curve',
                        choices = c('N64' = 'n64_sounds', 'Melee' = 'melee_sounds', 'Brawl' = 'brawl_sounds', 'Smash4' = 'smash4_sounds', 'Ultimate' = 'ultimate_sounds'),
                        selected = 'ultimate_sounds'),
    selectInput('hide_me', label = '', choices = '')
  ), 
  dashboardBody(
    #titlePanel('SUPER STATS BROS'),
    box(
      highchartOutput('main_plot'),
      textOutput('omitted'),
      background = "green",
      width = 12
    ),
    box(
      dataTableOutput('main_datatable'),
      width = 12
    )
  ),
  shinyjs::useShinyjs()
)