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
#
# Indexes
#
#  index_trades_on_traded_at  (traded_at)
#

class Trade < ActiveRecord::Base
  SOURCES = [
    BINANCE  = :binance,
    BITMEX   = :bitmex,
    COIN_API = :coin_api
  ].freeze

  TAKER_SIDES = [
    BUY = "BUY".freeze,
    SELL = "SELL".freeze
  ].freeze

  VISUALIZATION_GROUP_BYS = [
    DEFAULT_VISUALIZATION_GROUP_BY = GROUP_BY_MINUTE = :minute,
    GROUP_BY_HOUR = :hour,
    GROUP_BY_DAY = :day
  ].freeze

  DEFAULT_MOVING_AVERAGE_N = 4
  DEFAULT_VISUALIZATION_LIMIT = 1

  before_validation :calculate_flow

  scope :binance, -> { where(source: BINANCE) }
  scope :bitmex, -> { where(source: BITMEX) }
  scope :coin_api, -> { where(source: COIN_API) }
  scope :buyer_side, -> { where(taker_side: BUY) }
  scope :seller_side, -> { where(taker_side: SELL) }

  private

  def calculate_flow
    if price.present? && quantity.present?
      self.flow = price * quantity
    end
  end
end
