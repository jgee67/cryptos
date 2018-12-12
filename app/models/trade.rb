# == Schema Information
#
# Table name: trades
#
#  id         :bigint(8)        not null, primary key
#  price      :float
#  quantity   :float
#  taker_side :string
#  traded_at  :datetime
#  source     :string
#  flow       :float
#
# Indexes
#
#  index_trades_on_traded_at  (traded_at)
#

class Trade < ActiveRecord::Base
  InvalidGroupBy = Class.new(ArgumentError)

  CSV_COLUMNS = %w{ traded_at taker_side price quantity flow }

  SOURCES = [
    BINANCE  = :binance,
    BITMEX   = :bitmex,
    COIN_API = :coin_api,
  ].freeze

  TAKER_SIDES = [
    BUY = "BUY".freeze,
    SELL = "SELL".freeze,
  ].freeze

  VISUALIZATION_GROUP_BYS = [
    GROUP_BY_SECOND = :second,
    DEFAULT_VISUALIZATION_GROUP_BY = GROUP_BY_MINUTE = :minute,
    GROUP_BY_HOUR = :hour,
    DEFAULT_WINDOW_UNIT = GROUP_BY_DAY = :day,
  ].freeze

  MOVING_AVERAGE_NUMERATORS = [
    1,
    4,
    7,
    12,
    24,
    DEFAULT_MOVING_AVERAGE_NUMERATOR = 30,
  ].freeze

  MOVING_AVERAGE_DENOMINATORS = [
    1,
    5,
    10,
    DEFAULT_MOVING_AVERAGE_DENOMINATOR = 30,
    60,
    120,
  ].freeze

  WINDOW_SIZES = [
    1,
    3,
    DEFAULT_WINDOW_SIZE = 7,
    14,
    21,
    30,
    60,
  ].freeze

  before_validation :calculate_flow

  scope :binance, -> { where(source: BINANCE) }
  scope :bitmex, -> { where(source: BITMEX) }
  scope :coin_api, -> { where(source: COIN_API) }
  scope :buyer_side, -> { where(taker_side: BUY) }
  scope :seller_side, -> { where(taker_side: SELL) }
  scope :variable_group_by, -> (group_by, field, range) do
    case group_by
    when Trade::GROUP_BY_SECOND
      group_by_second(field, range: range)
    when Trade::GROUP_BY_MINUTE
      group_by_minute(field, range: range)
    when Trade::GROUP_BY_HOUR
      group_by_hour(field, range: range)
    when Trade::GROUP_BY_DAY
      group_by_day(field, range: range)
    else
      raise InvalidGroupBy
    end
  end

  private

  def calculate_flow
    if price.present? && quantity.present?
      self.flow = price * quantity
    end
  end
end
