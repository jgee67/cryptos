class AddIndexTradedAt < ActiveRecord::Migration[5.2]
  def change
    add_index :trades, :traded_at
  end
end
