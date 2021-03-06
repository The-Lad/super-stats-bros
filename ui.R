# UI functions
ui<- dashboardPage(
  header = dashboardHeader(title = span(tags$img(
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
  
  sidebar = dashboardSidebar(
    tags$head(tags$script(paste0('var dimension = [0, 0];
                                $(document).on("shiny:connected", function(e) {
                                    Shiny.onInputChange("start_audio", 0);
                                    dimension[0] = window.innerWidth;
                                    dimension[1] = window.innerHeight;
                                    Shiny.onInputChange("dimension", dimension);
                                });
                                $(document).on("shiny:disconnected", function(e) {
                                  Shiny.onInputChange("end_audio", 0);
                                });
                              $(window).resize(function(e) {
                                    dimension[0] = window.innerWidth;
                                    dimension[1] = window.innerHeight;
                                    Shiny.onInputChange("dimension", dimension);
                                });
                            '))),
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
    actionBttn('swap_xy', 'Swap x and y axes'),
    prettyCheckbox('img_markers', label = 'Images as markers?', shape = 'curve'),
    prettyCheckbox('use_tiers_data', label = "Group by tier?", shape = 'curve'),
    hidden(
      switchInput(
        inputId = "tier_color_scheme",
        onLabel = 'dumpster \nto glory',
        offLabel = 'boring',
        label = "<i class=\"fa fa-grin-hearts\"></i>"
      )),
    prettyCheckbox('playsound', label = 'click 4 a surprise'),
    prettyCheckbox('use_roster_dt', label = 'Roster table?', value = TRUE),
    prettyCheckboxGroup('enabled_sounds', label = 'Use which sounds? (Older preferred)', shape = 'curve',
                        choices = c('N64' = 'n64_sounds', 'Melee' = 'melee_sounds', 'Brawl' = 'brawl_sounds', 'Smash4' = 'smash4_sounds', 'Ultimate' = 'ultimate_sounds'),
                        selected = 'ultimate_sounds'),
    # add_busy_gif(
    #   timeout = 10,
    #   src = "https://giphy.com/gifs/nintendo-super-smash-bros-ultimate-piranha-plant-324ZVOYdCuwN6ouTYn",
    #   height = 70, width = 70
    # ),
    textOutput('last_key'),
    actionButton('hide_me', label = '',
                 style = "color: black;
                     background-color: #222d32;
                     position: relative;
                     height: 4px;
                     width: 4px;
                     border-radius: 0px;
                     border-width: 0px")
  ), 
  body = dashboardBody(
    tags$style(HTML('/* body */
      .content-wrapper, .right-side {
        background-color: #e8c2e8
      }')),#00C0EF;
    fluidRow(
      box(
        highchartOutput('main_plot'),
        textOutput('omitted'),
        background = "black",
        width = 12
      ),
      box(
        background = 'black',
        width = 12,
        tags$img(src = 'img/choose_character.png', style = "padding-bottom: 0.5em;  display: block; margin-left: auto; margin-right: auto;"), 
        conditionalPanel(
          condition = "output.show_roster_dt == true",
          tags$style(paste0(
            '#test {
    cursor: url(css/clickhand.ani), url(css/Mouse3.cur), crosshair;
    }')
          ),
          div(id='test', dataTableOutput('roster_dt')),
          tags$script(HTML("
      Shiny.addCustomMessageHandler('background-color', 
      function(e) {
       if($('#roster_dt table').DataTable) {
        var color;
        for (let j=0; j < e.col.length; j++) {
          color = e.value[j];
          for (let i=0; i < e.row.length; i++) {
            $('#roster_dt table').DataTable().cell(e.row[i], e.col[j]).node().style.backgroundColor = color
          }
        }
       }
      });
    "))
        ),
        conditionalPanel(
          condition = "output.show_roster_dt == false",
          dataTableOutput('main_dt')
        )
      )
    ),
    useShinyjs(),
    use_waitress()
    #tagList(tags$script(src = "waiter-assets/waiter/please-wait.min.js"), 
  ),
  title="SUPER STATS BROS",
  
  skin = 'purple'
)