BINANCE_API_KEY = ENV.fetch('BINANCE_API_KEY')

headers = { "X-MBX-APIKEY"  => BINANCE_API_KEY }
params = {"symbol" => "BTCUSDT", "limit" => "1000" }

response = HTTParty.get('https://api.binance.com/api/v1/trades', headers: headers, query: params)

latest_traded_at = Trade.binance.order(:traded_at).last&.traded_at || 0

response.each do |obj|
  traded_at = Time.at(obj["time"].to_f / 1000)

  if traded_at > latest_traded_at
    taker_side = obj["isBuyerMaker"] ? Trade::SELL : Trade::BUY

    Trade.create(
      price: "%f" % obj["price"],
      quantity: "%f" % obj["qty"],
      taker_side: taker_side,
      traded_at: traded_at,
      source: Trade::BINANCE
    )
  end
end
