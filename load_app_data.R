source('data_constants.R')
char_colors <- readxl::read_excel('data/smash_colors.xlsx', sheet = 'Characters')

char_stats = readRDS('data/char_stats.rds')

all_plot_vars = setdiff(colnames(char_stats), c('character', 'color', 'series_color', 'icon_path',  'icon_url_path'))

js_searchbox = "function() {
            var chart = this,
            points = chart.series[0].points,
            searchInput = document.getElementById('input');
            
            function changeMatches() {
              points.forEach(function(point) {
                point.update({
                  color: null
                })
                if (point.name === searchInput.value) {
                  
                  point.update({
                    color: 'red'
                  })
                  chart.tooltip.refresh(point)
                }
              })
            }
            
            searchInput.addEventListener('keyup', changeMatches);"


jscode <- "shinyjs.init = function() {

var signaturePad = new SignaturePad(document.getElementById('signature-pad'), {
  backgroundColor: 'rgba(255, 255, 255, 0)',
  penColor: 'rgb(0, 0, 0)'
});
var saveButton = document.getElementById('save');
var cancelButton = document.getElementById('clear');

saveButton.addEventListener('click', function (event) {
  var data = signaturePad.toDataURL('image/png');

// Send data to server instead...
  window.open(data);
});

cancelButton.addEventListener('click', function (event) {
  signaturePad.clear();
});

}"