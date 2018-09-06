# == Schema Information
#
# Table name: trades
#
#  id         :bigint(8)        not null, primary key
#  price      :float
#  quantity   :float
#  taker_side :string
#  traded_at  :datetime
#

class Trade < ActiveRecord::Base

end
