$(document).ready(function() {
  
  var margin = {top: 30, right: 20, bottom: 30, left: 40},
      padding = {top: 0, right: 200, bottom: 0, left: 0},
      width = 960 - margin.left - margin.right,
      height = 500 - margin.top - margin.bottom;

  var x = d3.scale.linear()
    .range([0, width-padding.right]);

  var y = d3.scale.linear()
    .range([height, 0]);

  var color = d3.scale.ordinal()
                .range(colorbrewer.Blues[9]);

  var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

  var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

  var svg = d3.select("#scatter-plot").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  d3.json("/api/schools", function(data) {

    data = _.map(data.schools, function(school) {
      var data_index = 0;

      return {
        frpm: school.frpm_percent_eligible_k_12[0] === undefined ? 0 : +school.frpm_percent_eligible_k_12[0].percent, 
        partner_count: +school.sub_area_counts[data_index].count,
        id: school.id,
        enrollment: school.frpm_percent_eligible_k_12[0] === undefined ? 0 : +school.frpm_percent_eligible_k_12[0].enrollment,
        name: school.name
      };
    });

    var data_enrollment_max = _.max(data, function(item) { return item.enrollment; }).enrollment,
        data_enrollment_min = _.min(data, function(item) { return item.enrollment; }).enrollment,
        data_enrollment_group_size = (data_enrollment_max - data_enrollment_min)/10;

    var group_bucket = _.each(data, function(item) {
      item.group_bucket = Math.floor(item.enrollment/data_enrollment_group_size);
      item.group_bucket_label = Math.floor(data_enrollment_group_size) + " - " + Math.floor(data_enrollment_group_size * 2);
    });

    var group_bucket_scale = d3.scale.quantize()
                              .domain([data_enrollment_min, data_enrollment_max])
                              .range(d3.range(10));

    var label_for_scale = function(bucket) {
      var range = group_bucket_scale.invertExtent(bucket);
      return Math.round(range[0]) + " - " + Math.round(range[1]-1);
    };

    x.domain(d3.extent(data, function(d) { return d.frpm; })).nice();
    y.domain(d3.extent(data, function(d) { return d.partner_count; })).nice();

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
      .append("text")
        .attr("class", "label")
        .attr("x", width-padding.right)
        .attr("y", -6)
        .style("text-anchor", "end")
        .text("Percent Eligible (K-12) for Free/Reduced Price Meals");

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
      .append("text")
          .attr("class", "label")
          .attr("transform", "rotate(-90)")
          .attr("y", 6)
          .attr("dy", ".71em")
          .style("text-anchor", "end")
          .text("Community Partner Count")

      svg.selectAll(".dot")
          .data(data)
        .enter().append("circle")
          .attr("class", "dot tip_under link")
          .attr("data-title", function(d) { return d.name })
          .attr("data-url", function(d) { return "/schools/" + d.id })
          .attr("r", 5)
          .attr("cx", function(d) { return x(d.frpm); })
          .attr("cy", function(d) { return y(d.partner_count); })
          .style("fill", function(d) { return color(group_bucket_scale(d.enrollment)); });

      var legend = svg.selectAll(".legend")
                        .data(color.domain())
                      .enter().append("g")
                        .attr("class", "legend")
                        .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

      legend.append("rect")
          .attr("x", width - padding.right + 20)
          .attr("width", 18)
          .attr("height", 18)
          .style("fill", color);

      legend.append("text")
          .attr("x", width - padding.right + 44)
          .attr("y", 9)
          .attr("dy", ".35em")
          .style("text-anchor", "start")
          .text(function(d) { return label_for_scale(d); });

      svg.append("text")
          .attr("x", width - padding.right + 20)
          .attr("y", -20)
          .attr("dy", ".35em")
          .style("text-anchor", "start")
          .text("Enrollment");

      add_tipsy('.tip_under', {gravity: 'w', title: function(){return this.getAttribute('data-title')} });
      $('.dot.link').on('click', function(event) {
        event.preventDefault();
        window.location.href = this.getAttribute('data-url');
      });
  });
});