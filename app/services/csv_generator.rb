class CsvGenerator
  def initialize(trades)
    @trades = trades
  end

  def generate
    CSV.generate(headers: true) do |csv|
      csv << Trade::CSV_COLUMNS

      trades.each do |trade|
        csv << Trade::CSV_COLUMNS.map { |attr| trade.public_send(attr) }
      end
    end
  end

  private

  attr_reader :trades
end
