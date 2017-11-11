// the metrics data that powers the chart
var chartdata = [];

// Wait page loaded
$(function() {

  // Set the dimensions of the canvas / graph
  var margin = {top: 20, right: 20, bottom: 100, left: 50},
  width = $('#metrics').width() - margin.left - margin.right,
  height = 500 - margin.top - margin.bottom;

  // Set the ranges
  var x = d3.scaleTime().range([0, width]);
  var y = d3.scaleLinear().range([height, 0]);

  // Define the line
  var valueline = d3.line()
    .x(function(d) { return x(d.timestamp); })
    .y(function(d) { return y(d.value); });

  // Adds the svg canvas
  var svg = d3.select("#metrics")
    .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  // Scale the range of the data
  x.domain(d3.extent(chartdata, function(d) { return d.timestamp }));
  y.domain([0, d3.max(chartdata, function(d) { return d.value })]);

  // Add the value line path
  svg.append("path")
    .data([chartdata])
    .attr("class", "line")
    .attr("d", valueline);

  // Add the X Axis
  svg.append("g")
    .attr('class', 'x axis')
    .attr('transform', 'translate(0,' + height + ')')
    .call(d3.axisBottom(x).tickFormat(d3.timeFormat("%d/%m/%Y")))
    .selectAll("text")
      .style("text-anchor", "end")
      .attr("dx", "-0.8em")
      .attr("dy", '0.15em')
      .attr('transform', 'rotate(-65)');

  // Add the Y Axis
  svg.append("g")
    .attr('class', 'y axis')
    .call(d3.axisLeft(y));

  $('#show-metrics').click(function(e){
    e.preventDefault();
    $.getJSON("/metrics.json", {}, function(data){
      chartdata = [];
      for (var i in data) {
        chartdata.push({
            timestamp: data[i].timestamp,
            value: data[i].value
          });
      }
      // Sort the metrics by timestamp
      chartdata.sort(function(a, b){
        return a.timestamp - b.timestamp;
      });
      console.log(chartdata)
      updateChart()
    })
  });

  function updateChart(){
    // Scale the range of the data
    x.domain(d3.extent(chartdata, function(d) { return d.timestamp }));
    y.domain([0, d3.max(chartdata, function(d) { return d.value })]);
  
    // Select the section we want to apply our change to
    var svg = d3.select("#metrics").transition();
    console.log(svg.select(".line"))
    
    // Make the changes
    svg.select(".line")
      .duration(750)
      .attr("d", valueline(chartdata));

    // Change the x axis
    svg.select(".x.axis")
      .duration(750)
      .call(d3.axisBottom(x).tickFormat(d3.timeFormat("%d/%m/%Y")))    
      .selectAll("text")
      .style("text-anchor", "end")
      .attr("dx", "-0.8em")
      .attr("dy", '0.15em')
      .attr('transform', 'rotate(-65)');
  
    // Change the y axis
    svg.select(".y.axis")
      .duration(750)
      .call(d3.axisLeft(y));
  }
});