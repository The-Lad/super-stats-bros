# UI functions
ui<- dashboardPage(
  #setBackgroundColor("#FFFFFF"),
  dashboardHeader(title = span(tags$img(
    src = 'img/super stats bros.png',
    title = "Title", height = "20px",
    alt = "SUPER STATS BROS"
  )),
  
  tags$li(
    a(
      href = 'https://www.harmonic.co.nz/',
      img(
        src = 'img/harmonic_logo.png', alt = "Made by Harmonic",
        title = "Company Home", height = "50px"),
      style = "padding-top:0px; padding-bottom:0px;"),
    class = "dropdown",
    style = "padding-left: 0vw;"
  )
  ), 
  dashboardSidebar(
    tags$script('
    $(document).on("keypress", function (e) {
       Shiny.onInputChange("keyseq", e.which);
    });
  ') ,
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
    textOutput('last_key'),
    # tags$head(
    #   tags$style(HTML("#hide_me{background-color:'#526980'}"))
    # ),
    actionButton('hide_me', label = '',
    style = "color: black;
                     background-color: #222d32;
                     position: relative;
                     height: 4px;
                     width: 4px;
                     border-radius: 0px;
                     border-width: 0px")
  ), 
dashboardBody(
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
# tags$head(
#   includeCSS("fonts.css")
# ),
shinyjs::useShinyjs()
)