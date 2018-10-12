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

  MOVING_AVERAGE_N = 4

  before_validation :calculate_flow

  scope :binance, -> { where(source: BINANCE) }
  scope :bitmex, -> { where(source: BITMEX) }
  scope :coin_api, -> { where(source: COIN_API) }
  scope :since_n_days_ago, -> (n) { where(traded_at: n.days.ago.beginning_of_day.utc..DateTime.now.utc) }
  scope :buyer_side, -> { where(taker_side: BUY) }
  scope :seller_side, -> { where(taker_side: SELL) }

  private

  def calculate_flow
    if price.present? && quantity.present?
      self.flow = price * quantity
    end
  end
end
