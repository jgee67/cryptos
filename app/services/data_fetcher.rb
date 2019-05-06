class DataFetcher
  BINANCE_API_KEY = ENV.fetch('BINANCE_API_KEY')
  BITMEX_API_KEY = ENV.fetch('BITMEX_API_KEY')
  BITMEX_API_SECRET = ENV.fetch('BITMEX_API_SECRET')
  WAIT_TIME_IN_SECONDS = 30
  MAXIMUM_TRADE_THRESHOLD = 9_000_000
  COUNT_TRADES_TO_PURGE = 3_000_000

  def self.queue_job
    codes = fetch_data

    if Trade.count > MAXIMUM_TRADE_THRESHOLD
      first_trade_id = Trade.first.id
      upper_id_bound = first_trade_id + COUNT_TRADES_TO_PURGE
      Trade.where(id: first_trade_id..upper_id_bound).delete_all
    end

    case codes
    when codes.any? { |v| v == 429 } # rate limit reached
      DataFetcher.delay(run_at: (WAIT_TIME_IN_SECONDS*2).seconds.from_now).queue_job
    when codes.any? { |v| v == 418 } # ip ban for rate limit
    else
      DataFetcher.delay(run_at: WAIT_TIME_IN_SECONDS.seconds.from_now).queue_job
    end
  end

  def self.fetch_data
    response_codes = []
    response_codes << fetch_binance_data
    response_codes << fetch_bitmex_data

    return response_codes
  end

  def self.fetch_binance_data
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

    response.code
  end

  def self.fetch_bitmex_data
    expires = 1.minute.from_now.to_i.to_s

    latest_traded_at = 1.minute.ago
    params = { 'filter' => { 'symbol' => "XBTUSD", 'startTime' => latest_traded_at.strftime("%Y-%m-%d %H:%M") }, 'count' => 500 }
    headers = { "api-expires"  => expires, 'api-key' => BITMEX_API_KEY, 'api-signature' => bitmex_api_signature(expires, params) }

    response = HTTParty.get('https://www.bitmex.com' + bitmex_path(params), headers: headers)

    if response.code == 200

      response.each do |obj|
        traded_at = DateTime.parse(obj['timestamp'])

        if traded_at > latest_traded_at
          taker_side = obj["side"] == "Sell" ? Trade::SELL : Trade::BUY
          price = ("%f" % obj["price"]).to_f
          quantity = ("%f" % obj["foreignNotional"]).to_f / price

          Trade.create(
            price: price,
            quantity: quantity,
            taker_side: taker_side,
            traded_at: traded_at,
            source: Trade::BITMEX
          )
        end
      end
    end

    response.code
  end

  def self.bitmex_path(params)
    query_params = params.each_with_object([]) do |(key, value), result|
      result << key.to_s + '=' + ERB::Util.url_encode(value.to_json)
    end.join('&')
    path = '/api/v1/trade'
    path += '?' + query_params if query_params.present?
    path
  end

  def self.bitmex_api_signature(expires, params)
    path = bitmex_path(params)
    secret = BITMEX_API_SECRET
    verb = 'GET'
    data = verb + path + expires
    digest = OpenSSL::Digest.new('sha256')
    OpenSSL::HMAC.hexdigest(digest, secret, data)
  end
end
