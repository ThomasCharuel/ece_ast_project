# the metrics data that powers the chart
chartdata = []

# Wait page loaded
$ () ->

  # Initiate datepicker
  $('#metric_datepicker').datepicker()

  # Set the dimensions of the canvas / graph
  margin = {top: 20, right: 20, bottom: 100, left: 50}
  width = $('#metrics').width() - margin.left - margin.right
  height = 400 - margin.top - margin.bottom

  # Set the ranges
  x = d3.scaleTime().range [0, width]
  y = d3.scaleLinear().range [height, 0]

  # Define the line
  valueline = d3.line()
    .x (d) -> x d.timestamp
    .y (d) -> y d.value

  # Adds the svg canvas
  svg = d3.select "#metrics"
    .append "svg"
      .attr "width", width + margin.left + margin.right
      .attr "height", height + margin.top + margin.bottom
    .append "g"
      .attr "transform", "translate(" + margin.left + "," + margin.top + ")"

  # Scale the range of the data
  x.domain d3.extent chartdata, (d) -> d.timestamp
  y.domain [0, d3.max chartdata, (d) -> d.value ]

  # Add the value line path
  svg.append "path"
    .data [chartdata]
    .attr "class", "line"
    .attr "d", valueline

  # Add the X Axis
  svg.append "g"
    .attr 'class', 'x axis'
    .attr 'transform', 'translate(0,' + height + ')'
    .call d3.axisBottom(x).tickFormat d3.timeFormat "%d/%m/%Y"
    .selectAll "text"
      .style "text-anchor", "end"
      .attr "dx", "-0.8em"
      .attr "dy", '0.15em'
      .attr 'transform', 'rotate(-65)'

  # Add the Y Axis
  svg.append "g"
    .attr 'class', 'y axis'
    .call d3.axisLeft y

  $('#show-metrics').click (e) ->
    e.preventDefault()
    $.getJSON "/metrics.json", {}, (data) ->
      chartdata = []
      for d in data
        chartdata.push
            timestamp: d.timestamp,
            value: d.value
      # Sort the metrics by timestamp
      chartdata.sort (a, b) -> a.timestamp - b.timestamp
      updateChart()

  $('#newMetric').submit (e) ->
    e.preventDefault()
    id = $("#metric_id").val()
    date = (new Date $("#metric_datepicker").val() ).getTime()
    value = $("#metric_value").val()
    


  updateChart = () ->
    # Scale the range of the data
    x.domain d3.extent chartdata, (d) -> d.timestamp
    y.domain [0, d3.max chartdata, (d) -> d.value ]
  
    # Select the section we want to apply our change to
    svg = d3.select "#metrics"
      .transition()
    
    # Make the changes
    svg.select ".line"
      .duration 750
      .attr "d", valueline chartdata

    # Change the x axis
    svg.select ".x.axis"
      .duration 750
      .call d3.axisBottom(x).tickFormat d3.timeFormat "%d/%m/%Y"  
      .selectAll "text"
      .style "text-anchor", "end"
      .attr "dx", "-0.8em"
      .attr "dy", '0.15em'
      .attr 'transform', 'rotate(-65)'
  
    # Change the y axis
    svg.select ".y.axis"
      .duration 750
      .call d3.axisLeft y