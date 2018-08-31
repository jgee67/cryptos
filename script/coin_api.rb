require 'csv'

COIN_API_KEY = "1AB4876F-371E-42CC-9E04-12694F807C81"

headers = { "X-CoinAPI-Key"  => COIN_API_KEY }

response = HTTParty.get('https://rest.coinapi.io/v1/trades/BINANCE_SPOT_BTC_USDT/latest', headers: headers)

CSV.open("coin_api.csv", "w") do |csv|
  csv << ["price", "size", "taker_side"]
  response.each do |obj|
    csv << ["%f" % obj["price"], obj["size"], obj["taker_side"]]
  end
end
