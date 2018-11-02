class TradesController < ApplicationController
  def index
    @group_by ||= params.fetch(:group_by, Trade::DEFAULT_VISUALIZATION_GROUP_BY)
  end

  def chart_data
    # range = params.fetch(:limit, Trade::DEFAULT_VISUALIZATION_LIMIT).to_i.days.ago..Time.now
    range = Trade.minimum(:traded_at)..Trade.maximum(:traded_at)
    group_by = params.fetch(:group_by, Trade::DEFAULT_VISUALIZATION_GROUP_BY).to_sym
    moving_average_n = params.fetch(:moving_average_n, Trade::DEFAULT_MOVING_AVERAGE_N).to_i

    grouped_buys = Trade.binance.buyer_side.variable_group_by(group_by, :traded_at, range).sum(:flow)
    grouped_sells = Trade.binance.seller_side.variable_group_by(group_by, :traded_at, range).sum(:flow)

    overlapping_minutes = grouped_buys.keys & grouped_sells.keys

    result = overlapping_minutes.each_with_object({}).each_with_index do |(minute, result), i|
      result[:flow_difference] ||= {}
      result[:moving_average] ||= {}

      result[:flow_difference][minute] = grouped_buys[minute] - grouped_sells[minute]
      starting_index = i - (moving_average_n - 1)
      if starting_index >= 0
        minutes_to_average = overlapping_minutes[starting_index..i]
        result[:moving_average][minute] = result[:flow_difference].slice(*minutes_to_average).values.sum / moving_average_n
      end
    end

    render json: [
        { name: 'Flow (buys - sells)', data: result[:flow_difference] },
        { name: 'Moving Average', data: result[:moving_average] }
      ],
      status: :ok
  end
end
