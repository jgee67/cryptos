module TradeHelper
  def export_button(starting_time:, ending_time:)
    month = starting_time.strftime("%B")
    button_to "Export #{month} Trades", { controller: :trades, action: :export, starting_time: starting_time, ending_time: ending_time, format: :csv }, { id: "export_button_#{month}" }
  end
end
