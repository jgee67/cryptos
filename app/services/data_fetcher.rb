class DataFetcher
  BINANCE_API_KEY = ENV.fetch('BINANCE_API_KEY')
  WAIT_TIME_IN_MINUTES = 3

  def self.fetch_data
    headers = { "X-MBX-APIKEY"  => BINANCE_API_KEY }
    params = {"symbol" => "BTCUSDT", "limit" => "1000" }

    response = HTTParty.get('https://api.binance.com/api/v1/trades', headers: headers, query: params)

    if response.code == 200
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
    end

    return response.code
  end

  def self.queue_job
    code = fetch_data

    case code
    when 429 # rate limit reached
      DataFetcher.delay(run_at: (WAIT_TIME_IN_MINUTES*2).minutes.from_now).queue_job
    when 418 # ip ban for rate limit
    else
      DataFetcher.delay(run_at: WAIT_TIME_IN_MINUTES.minutes.from_now).queue_job
    end
  end
end
