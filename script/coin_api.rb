require 'csv'

COIN_API_KEY = ENV.fetch('COIN_API_KEY')
SYMBOL_LIST = [
  "BINANCE_SPOT_BTC_USDT",
  "BITLISH_SPOT_BTC_USDT",
  "UPBIT_SPOT_BTC_USDT",
  "ACX_SPOT_BTC_USDT",
  "WEXNZ_SPOT_BTC_USDT",
  "DSX_SPOT_BTC_USDT",
  "BLEUTRADE_SPOT_BTC_USDT",
  "BRAZILIEX_SPOT_BTC_USDT",
  "TIDEX_SPOT_BTC_USDT",
  "KUCOIN_SPOT_BTC_USDT",
  "EXMO_SPOT_BTC_USDT",
  "GATEIO_SPOT_BTC_USDT",
  "CRYPTOPIA_SPOT_BTC_USDT",
  "LIQUI_SPOT_BTC_USDT",
  "OKEX_SPOT_BTC_USDT",
  "HITBTC_SPOT_BTC_USDT",
  "HUOBIPRO_SPOT_BTC_USDT",
  "BITTREX_SPOT_BTC_USDT",
  "POLONIEX_SPOT_BTC_USDT"
]

headers = { "X-CoinAPI-Key"  => COIN_API_KEY }

response = HTTParty.get('https://rest.coinapi.io/v1/trades/BINANCE_SPOT_BTC_USDT/latest', headers: headers)

CSV.open("coin_api.csv", "w") do |csv|
  csv << ["price", "size", "taker_side"]
  response.each do |obj|
    csv << ["%f" % obj["price"], obj["size"], obj["taker_side"]]
  end
end
