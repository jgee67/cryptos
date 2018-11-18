desc 'Continuously fetch data from binance api'
task binance: :environment do
  DataFetcher.queue_job
end
