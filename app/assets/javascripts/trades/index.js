$(document).ready(function() {
  $("#apply_button").click(function() {
    var chart = Chartkick.charts["chart-1"];
    var dataUrl = chart.getDataSource();
    var baseUrl = dataUrl.slice(0, dataUrl.indexOf('?'))
    var params = [];

    var group_by_param = $('input[name="group_by"]:checked').val();
    params.push('group_by=' + group_by_param);
    var moving_average_numerator_param = $('input[name="moving_average_numerator"]:checked').val();
    params.push('moving_average_numerator=' + moving_average_numerator_param);
    var moving_average_denominator_param = $('input[name="moving_average_denominator"]:checked').val();
    params.push('moving_average_denominator=' + moving_average_denominator_param);
    var window_unit_param = $('input[name="window_unit"]:checked').val();
    params.push('window_unit=' + window_unit_param);
    var window_size_param = $('input[name="window_size"]:checked').val();
    params.push('window_size=' + window_size_param);

    var newUrl = baseUrl + '?' + params.join('&');
    chart.updateData(newUrl);
  });
});
