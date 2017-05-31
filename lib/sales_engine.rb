require './lib/merchant_repository'
require './lib/item_repository'

class SalesEngine

  attr_reader :merchants, :items

  def initialize(item_merchant_hash)
    @items = ItemRepository.new(item_merchant_hash[:items])
    @merchants = MerchantRepository.new(item_merchant_hash[:merchants])
  end


  def self.from_csv(item_merchant_hash)
    se = SalesEngine.new(item_merchant_hash)
  end

end

se = SalesEngine.from_csv({
  :items     => "./data/items.csv",
  :merchants => "./data/merchants.csv",
})
merchant = se.merchants.find_by_id(12334112)
merchant.items
# => [<item>, <item>, <item>]
item = se.items.find_by_id(263395237)
item.merchant
# => <merchant>
