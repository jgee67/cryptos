class TradesController < ApplicationController
  def index
  end

  def chart_data
    window_size = params.fetch(:window_size, Trade::DEFAULT_WINDOW_SIZE).to_i
    range = window_size.to_i.days.ago..Time.now
    # range = Trade.minimum(:traded_at)..Trade.maximum(:traded_at)
    group_by = params.fetch(:group_by, Trade::DEFAULT_VISUALIZATION_GROUP_BY).to_sym
    moving_average_numerator = params.fetch(:moving_average_numerator, Trade::DEFAULT_MOVING_AVERAGE_NUMERATOR).to_i
    moving_average_denominator = params.fetch(:moving_average_denominator, Trade::DEFAULT_MOVING_AVERAGE_DENOMINATOR).to_i

    grouped_buys = Trade.binance.buyer_side.variable_group_by(group_by, :traded_at, range).sum(:flow)
    grouped_sells = Trade.binance.seller_side.variable_group_by(group_by, :traded_at, range).sum(:flow)

    overlapping_group_by_units = grouped_buys.keys & grouped_sells.keys

    result = overlapping_group_by_units.each_with_object({}).each_with_index do |(group_by_unit, result), i|
      result[:flow_difference] ||= {}
      result[:moving_average] ||= {}

      result[:flow_difference][group_by_unit] = grouped_buys[group_by_unit] - grouped_sells[group_by_unit]
      starting_index = i - (moving_average_numerator - 1)
      if starting_index >= 0
        group_by_units_to_average = overlapping_group_by_units[starting_index..i]
        result[:moving_average][group_by_unit] = result[:flow_difference].slice(*group_by_units_to_average).values.sum / moving_average_denominator
      end
    end

    render json: [
        { name: 'Flow (buys - sells)', data: result[:flow_difference] },
        { name: 'Moving Average', data: result[:moving_average] }
      ],
      status: :ok
  end
end
