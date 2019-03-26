class TradesController < ApplicationController
  def index
    export_dates_hash = Trade.group_by_week(:traded_at).minimum(:traded_at).keys.each_with_object({}) do |first_of_week, result|
      result[first_of_week] = (first_of_week + 1.day).at_end_of_week
    end

    render template: 'trades/index', locals: { export_dates_hash: export_dates_hash }
  end

  def binance_chart_data
    starting_time = params.fetch(:start_date, Date.today).to_date.at_beginning_of_day
    ending_time = params.fetch(:end_date, Trade::DEFAULT_WINDOW_SIZE.days.from_now).to_date.at_end_of_day
    range = starting_time..ending_time
    group_by = params.fetch(:group_by, Trade::DEFAULT_VISUALIZATION_GROUP_BY).to_sym
    moving_average_numerator = params.fetch(:moving_average_numerator, Trade::DEFAULT_MOVING_AVERAGE_NUMERATOR).to_i
    moving_average_denominator = params.fetch(:moving_average_denominator, Trade::DEFAULT_MOVING_AVERAGE_DENOMINATOR).to_i

    base_query = Trade.binance.where(traded_at: range).variable_group_by(group_by, :traded_at, range)
    grouped_buys = base_query.buyer_side.sum(:flow)
    grouped_sells = base_query.seller_side.sum(:flow)
    grouped_prices = base_query.average(:price)

    overlapping_group_by_units = grouped_buys.keys & grouped_sells.keys

    result = overlapping_group_by_units.each_with_object({}).each_with_index do |(group_by_unit, result), i|
      result[:flow_difference] ||= {}
      result[:moving_average] ||= {}
      result[:average_price] ||= {}

      result[:flow_difference][group_by_unit] = grouped_buys[group_by_unit] - grouped_sells[group_by_unit]
      starting_index = i - (moving_average_numerator - 1)
      if starting_index >= 0
        group_by_units_to_average = overlapping_group_by_units[starting_index..i]
        result[:moving_average][group_by_unit] = result[:flow_difference].slice(*group_by_units_to_average).values.sum / moving_average_denominator
      end
    end

    result[:average_price] = grouped_prices

    render json: [
        { name: 'Flow (buys - sells)', data: result[:flow_difference] },
        { name: 'Moving Average', data: result[:moving_average] },
        { name: 'Price', data: result[:average_price] }
      ],
      status: :ok
  end

  def bitmex_chart_data
    starting_time = params.fetch(:start_date, Date.today).to_date.at_beginning_of_day
    ending_time = params.fetch(:end_date, Trade::DEFAULT_WINDOW_SIZE.days.from_now).to_date.at_end_of_day
    range = starting_time..ending_time
    group_by = params.fetch(:group_by, Trade::DEFAULT_VISUALIZATION_GROUP_BY).to_sym
    moving_average_numerator = params.fetch(:moving_average_numerator, Trade::DEFAULT_MOVING_AVERAGE_NUMERATOR).to_i
    moving_average_denominator = params.fetch(:moving_average_denominator, Trade::DEFAULT_MOVING_AVERAGE_DENOMINATOR).to_i

    base_query = Trade.bitmex.where(traded_at: range).variable_group_by(group_by, :traded_at, range)
    grouped_buys = base_query.buyer_side.sum(:flow)
    grouped_sells = base_query.seller_side.sum(:flow)
    grouped_prices = base_query.average(:price)

    overlapping_group_by_units = grouped_buys.keys & grouped_sells.keys

    result = overlapping_group_by_units.each_with_object({}).each_with_index do |(group_by_unit, result), i|
      result[:flow_difference] ||= {}
      result[:moving_average] ||= {}
      result[:average_price] ||= {}

      result[:flow_difference][group_by_unit] = grouped_buys[group_by_unit] - grouped_sells[group_by_unit]
      starting_index = i - (moving_average_numerator - 1)
      if starting_index >= 0
        group_by_units_to_average = overlapping_group_by_units[starting_index..i]
        result[:moving_average][group_by_unit] = result[:flow_difference].slice(*group_by_units_to_average).values.sum / moving_average_denominator
      end
    end

    result[:average_price] = grouped_prices

    render json: [
        { name: 'Flow (buys - sells)', data: result[:flow_difference] },
        { name: 'Moving Average', data: result[:moving_average] },
        { name: 'Price', data: result[:average_price] }
      ],
      status: :ok
  end

  def export
    respond_to do |format|
      format.csv do
        starting_time = params.fetch(:starting_time).to_datetime
        ending_time = params.fetch(:ending_time).to_datetime
        filename =
        trades = Trade.where(traded_at: starting_time..ending_time)

        send_data CsvGenerator.new(trades).generate, filename: "#{starting_time.strftime("%Y_%b%d")}_#{ending_time.strftime("%Y_%b%d")}.csv"
      end
    end
  end
end
