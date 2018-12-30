$(document).ready(function() {
  $(".datetimepicker").datetimepicker();

  $("#apply_button").click(function() {
    var chart = Chartkick.charts["chart-1"];
    var dataUrl = chart.getDataSource();
    var baseUrl = dataUrl.slice(0, dataUrl.indexOf('?'))
    var params = [];
    var startTime = $("#datepicker-start").val();
    var endTime = $("#datepicker-end").val();

    var group_by_param = $('input[name="group_by"]:checked').val();
    params.push('group_by=' + group_by_param);
    var moving_average_numerator_param = $('input[name="moving_average_numerator"]:checked').val();
    params.push('moving_average_numerator=' + moving_average_numerator_param);
    var moving_average_denominator_param = $('input[name="moving_average_denominator"]:checked').val();
    params.push('moving_average_denominator=' + moving_average_denominator_param);
    params.push('start_date=' + startTime);
    params.push('end_date=' + endTime);

    var newUrl = baseUrl + '?' + params.join('&');
    chart.updateData(newUrl);
  });
});
