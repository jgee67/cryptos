$(document).ready(function() {
  $(".datetimepicker").datetimepicker();

  $("#apply_button").click(function() {
    var binanceChart = Chartkick.charts["chart-1"];
    var binanceDataUrl = binanceChart.getDataSource();
    var binanceBaseUrl = binanceDataUrl.slice(0, binanceDataUrl.indexOf('?'));
    var bitmexChart = Chartkick.charts["chart-2"];
    var bitmexDataUrl = bitmexChart.getDataSource();
    var bitmexBaseUrl = bitmexDataUrl.slice(0, bitmexDataUrl.indexOf('?'));
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

    var newBinanceUrl = binanceBaseUrl + '?' + params.join('&');
    binanceChart.updateData(newBinanceUrl);
    var newBitmexUrl = bitmexBaseUrl + '?' + params.join('&');
    bitmexChart.updateData(newBitmexUrl);
  });
});
