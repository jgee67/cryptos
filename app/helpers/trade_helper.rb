module TradeHelper
  def export_button(starting_time:, ending_time:)
    stringified_time_range = "#{starting_time.strftime("%b%d")}_#{ending_time.strftime("%b%d")}"
    button_to "Export #{starting_time.strftime("%Y")} #{stringified_time_range} Trades", { controller: :trades, action: :export, starting_time: starting_time, ending_time: ending_time, format: :csv }, { id: "export_button_#{stringified_time_range}" }
  end
end
