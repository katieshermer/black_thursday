require 'bigdecimal'
require 'bigdecimal/util'

class Item
  attr_reader :id, :name, :description, :unit_price, :merchant_id, :created_at, :updated_at

  def initialize(item_hash)
    @id = item_hash[:id].to_i
    @name = item_hash[:name]
    @description = item_hash[:description]
    @unit_price = item_hash[:unit_price].to_s.insert(-3, ".").to_f.to_d unless item_hash[:unit_price] == nil
    @merchant_id = item_hash[:merchant_id]
    @created_at = item_hash[:created_at]
    @updated_at = item_hash[:updated_at]
  end

end

item = Item.new({:unit_price => 3900})
puts item.unit_price
