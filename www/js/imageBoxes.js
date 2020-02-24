// valueIBox
window.FlexDashboardComponents.push({
  
  type: "custom",
  
  find: function(container) {
    if (container.find('span.valueI-output, .shiny-valueIbox-output').length)
      return container;
    else
      return $();
  },
  
  flex: function(fillPage) {
    return false;
  },
  
  layout: function(title, container, element, fillPage) {
    
    // alias variables
    var chartTitle = title;
    var valueIBox = element;
    
    // add valueI-box class to container
    container.addClass('valueI-box');
    
    // valueI paragraph
    var valueI = $('<p class="valueI"></p>');
    
    // if we have shiny-text-output then just move it in
    var valueIOutputSpan = [];
    var shinyOutput = valueIBox.find('.shiny-valueIbox-output').detach();
    if (shinyOutput.length) {
      valueIBox.children().remove();
      shinyOutput.html("&mdash;");
      valueI.append(shinyOutput);
    } else {
      // extract the valueI (remove leading vector index)
      var chartvalueI = valueIBox.text().trim();
      chartvalueI = chartvalueI.replace("[1] ", "");
      valueIOutputSpan = valueIBox.find('span.valueI-output').detach();
      valueIBox.children().remove();
      valueI.text(chartvalueI);
    }
    
    // caption
    var caption = $('<p class="caption"></p>');
    caption.html(chartTitle);
    
    // build inner div for valueI box and add it
    var inner = $('<div class="inner"></div>');
    inner.append(valueI);
    inner.append(caption);
    valueIBox.append(inner);
    
    // add plot if specified
    var chartPlot = valueIBox.attr('data-plot');
    
    var plot = $(('<img class="Iplot"/>'));
    valueIBox.append(plot);
    
    function setImage(chartPlot) {
      plot.attr("src", 'www/' + chartPlot);
    }
    
    if (chartPlot)
      setImage(chartPlot);
    
    //'<img class="img img-local" src="www/' + 'trend_plot.jpg' + '" width="80px"/>'
    
    // set color based on data-background if necessary
    var dataBackground = valueIBox.attr('data-background');
    if (dataBackground)
      valueIBox.css('background-color', bgColor);
    else {
      // default to bg-primary if no other background is specified
      if (!valueIBox.hasClass('bg-primary') &&
          !valueIBox.hasClass('bg-info') &&
          !valueIBox.hasClass('bg-warning') &&
          !valueIBox.hasClass('bg-success') &&
          !valueIBox.hasClass('bg-danger')) {
        valueIBox.addClass('bg-primary');
      }
    }
    
    // handle data attributes in valueIOutputSpan
    function handleValueIOutput(valueIOutput) {
      
      // caption
      var dataCaption = valueIOutput.attr('data-caption');
      if (dataCaption)
        caption.html(dataCaption);
      
      // plot
      var dataPlot = valueIOutput.attr('data-plot');
      
      var plot = $(('<img class="Iplot"/>'));
      valueIBox.append(plot);
      
      if (dataPlot)
        setImage(dataPlot);
      
      
      // color
      var dataColor = valueIOutput.attr('data-color');
      if (dataColor) {
        if (dataColor.indexOf('bg-') === 0) {
          valueIBox.css('background-color', '');
          if (!valueIBox.hasClass(dataColor)) {
            valueIBox.removeClass('bg-primary bg-info bg-warning bg-danger bg-success');
            valueIBox.addClass(dataColor);
          }
        } else {
          valueIBox.removeClass('bg-primary bg-info bg-warning bg-danger bg-success');
          valueIBox.css('background-color', dataColor);
        }
      }
      
      // url
      var dataHref = valueIOutput.attr('data-href');
      if (dataHref) {
        valueIBox.addClass('linked-valueI');
        valueIBox.off('click.valueI-box');
        valueIBox.on('click.valueI-box', function(e) {
          window.FlexDashboardUtils.showLinkedValue(dataHref);
        });
      }
    }
    
    // check for a valueIOutputSpan
    if (valueIOutputSpan.length > 0) {
      handleValueIOutput(valueIOutputSpan);
    }
    
    // if we have a shinyOutput then bind a listener to handle
    // new valueIOutputSpan values
    shinyOutput.on('shiny:value',
                   function(event) {
                     var element = $(event.target);
                     setTimeout(function() {
                       var valueIOutputSpan = element.find('span.valueI-output');
                       if (valueIOutputSpan.length > 0)
                         handleValueIOutput(valueIOutputSpan);
                     }, 10);
                   }
    );
  }
});