require 'csv'

BINANCE_API_KEY = "yIQhcDsGApIUoQHcwCGEFRImbmEPJthwlB3VBeR4lNfsOaj5z2nlM2zKdSrDIVtK"

headers = { "X-MBX-APIKEY"  => BINANCE_API_KEY }
params = {"symbol" => "BTCUSDT" }

response = HTTParty.get('https://api.binance.com/api/v1/trades', headers: headers, query: params)

CSV.open("binance_api.csv", "w") do |csv|
  csv << ["price", "size", "taker_side"]
  response.each do |obj|
    taker_side = obj["isBuyerMaker"] ? "SELL" : "BUY"
    csv << ["%f" % obj["price"], "%f" % obj["qty"], taker_side]
  end
end
