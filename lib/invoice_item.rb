require 'bigdecimal'
require 'bigdecimal/util'

class InvoiceItem

  attr_reader :id,
              :item_id,
              :invoice_id,
              :quantity,
              :unit_price,
              :created_at,
              :updated_at

  def initialize(invoice_item_hash, invoice_item_repo)
    @invoice_item_repo = invoice_item_repo
    @id = invoice_item_hash[:id].to_i
    @item_id = invoice_item_hash[:item_id].to_i
    @invoice_id = invoice_item_hash[:invoice_id].to_i
    @quantity = invoice_item_hash[:quantity].to_i
    @unit_price = create_unit_price(invoice_item_hash[:unit_price])
    @created_at = invoice_item_hash[:created_at]
    @updated_at = invoice_item_hash[:updated_at]
  end

  def create_unit_price(unit_price)
    unless unit_price.nil?
      @unit_price = BigDecimal.new(unit_price) / 100
    end
  end


  def unit_price_to_dollars
    @unit_price.to_f.round(2)
  end

end
