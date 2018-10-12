class AddFlowToTrades < ActiveRecord::Migration[5.2]
  def change
    add_column :trades, :flow, :real
  end
end
