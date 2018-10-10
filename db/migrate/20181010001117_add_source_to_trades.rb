class AddSourceToTrades < ActiveRecord::Migration[5.2]
  def change
    add_column :trades, :source, :string
  end
end
