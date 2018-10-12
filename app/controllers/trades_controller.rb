class TradesController < ApplicationController
  def index
    grouped_buys = Trade.binance.buyer_side.since_n_days_ago(30).group_by_minute(:traded_at).sum(:flow)
    grouped_sells = Trade.binance.seller_side.since_n_days_ago(30).group_by_minute(:traded_at).sum(:flow)
    overlapping_minutes = grouped_buys.keys & grouped_sells.keys

    result = overlapping_minutes.each_with_object({}).each_with_index do |(minute, result), i|
      result[:flow_difference] ||= {}
      result[:moving_average] ||= {}

      result[:flow_difference][minute] = grouped_buys[minute] - grouped_sells[minute]
      starting_index = i - (Trade::MOVING_AVERAGE_N - 1)
      if starting_index >= 0
        minutes_to_average = overlapping_minutes[starting_index..i]
        result[:moving_average][minute] = result[:flow_difference].slice(*minutes_to_average).values.sum / Trade::MOVING_AVERAGE_N
      end
    end

    @binance_chart_data = [{ name: 'flow difference (buys - sells)', data: result[:flow_difference] }, { name: 'moving average', data: result[:moving_average] }]
  end
end
