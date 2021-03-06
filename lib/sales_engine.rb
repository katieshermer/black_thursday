require_relative 'merchant_repository'
require_relative 'item_repository'
require_relative 'invoice_repository'
require_relative 'invoice_item_repository'
require_relative 'customer_repository'
require_relative 'transaction_repository'

require 'pry'

class SalesEngine

  attr_reader :merchants,
              :item_repo,
              :invoice_repo,
              :invoice_items,
              :transactions,
              :customers

  def initialize(item_merchant_hash)
    @item_merchant_hash = item_merchant_hash
    @item_repo = ItemRepository.new(item_merchant_hash[:items], self)
    @merchants = MerchantRepository.new(item_merchant_hash[:merchants], self)
    @invoice_repo = InvoiceRepository.new(item_merchant_hash[:invoices], self)
    @invoice_items =
      create_invoice_item_repo(item_merchant_hash[:invoice_items])
    @transactions =
      create_transaction_repo(item_merchant_hash[:transactions])
    @customers =
      create_customers_repo(item_merchant_hash[:customers])
  end

  def self.from_csv(item_merchant_hash)
    SalesEngine.new(item_merchant_hash)
  end

  def create_invoice_item_repo(invoice_items_list)
    @invoice_items = InvoiceItemRepository.new(self)
    @invoice_items.from_csv(invoice_items_list)
    invoice_items = @invoice_items
  end

  def create_transaction_repo(transactions_list)
    @transactions = TransactionRepository.new(self)
    @transactions.from_csv(transactions_list)
    transactions = @transactions
  end

  def create_customers_repo(customers_list)
    @customers = CustomerRepository.new(self)
    @customers.from_csv(customers_list)
    customers = @customers
  end

  def merchant(merchant_id)
    @merchants.find_by_id(merchant_id)
  end

  def items(merchant_id = nil)
    if self.class == Item
      @item_repo.find_all_by_merchant_id(merchant_id)
    else
      @item_repo
    end
  end

  def find_items_by_merchant_id(merchant_id)
    @item_repo.find_all_by_merchant_id(merchant_id)
  end

  def invoices(merchant_id = nil)
    if self == Invoice
      @invoice_repo.find_all_by_merchant_id(merchant_id)
    else
      @invoice_repo
    end
  end

  def find_invoices_by_merchant_id(merchant_id)
    @invoice_repo.find_all_by_merchant_id(merchant_id)
  end

  def find_invoice_items_by_invoice_id(invoice_id)
    result = @invoice_items.find_all_by_invoice_id(invoice_id)
    result = extract_invoice_item_item_ids(result)
    find_items_by_multiple_item_ids(result)
  end

  def extract_invoice_item_item_ids(result)
    result = result.map do |invoice_item|
      invoice_item.item_id
    end
  end

  def find_items_by_multiple_item_ids(item_ids)
    @item_repo.find_by_multiple_item_ids(item_ids)
  end

  def find_transactions_by_invoice_id(invoice_id)
    @transactions.find_all_by_invoice_id(invoice_id)
  end

  def customer(customer_id)
    @customers.find_by_id(customer_id)
  end

  def find_invoice_by_transaction_invoice_id(invoice_id)
    @invoice_repo.find_by_id(invoice_id)
  end

  def find_customers_by_merchant_id(merchant_id)
    result = @invoice_repo.find_all_by_merchant_id(merchant_id)
    result = extract_customers(result)
    find_multiple_customers_by_id(result)
  end

  def extract_customers(invoices)
    invoices = invoices.map do |invoice|
      invoice.customer_id
    end
  end

  def find_multiple_customers_by_id(customer_ids)
    @customers.find_multiple_customers_by_id(customer_ids)
  end

  def find_merchants_by_customer_id(customer_id)
    invoices = @invoice_repo.find_all_by_customer_id(customer_id)
    merchant_ids = extract_merchants(invoices)
    find_multiple_merchants_by_id(merchant_ids)
  end

  def extract_merchants(invoices)
    invoices = invoices.map do |invoice|
      invoice.merchant_id
    end
  end

  def find_multiple_merchants_by_id(merchant_ids)
    @merchants.find_multiple_merchants_by_id(merchant_ids)
  end

  def find_merchant_by_invoice_id(merchant_id)
    @merchants.find_by_id(merchant_id)
  end

  def sales_engine_items_by_invoice_id(invoice_id)
    @item_repo.find_all_by_invoice_id(invoice_id)
  end

  def total(id)
    @invoice_items.total(id)
  end

  def is_paid_in_full?(invoice_id)
    @transactions.is_paid_in_full?(invoice_id)
  end

  def is_pending?(invoice_id)
    @transactions.is_pending?(invoice_id)
  end

  def find_all_items_by_invoices(invoices)
    @invoice_items.find_all_items_by_invoices(invoices)
  end

  def total_revenue_by_merchant_id(merchant_id)
    invoices = @invoice_repo.find_all_by_merchant_id(merchant_id)
    invoices = invoices.select{|invoice| invoice.is_pending? == false}
    total = invoices.reduce(0){|sum, invoice| sum + invoice.total}
  end

  def merchants_with_only_one_item
    all_merchant_ids = @item_repo.merchants_with_only_one_item
    single_item_merchants = extract_single_item_merchants(all_merchant_ids)
    find_multiple_merchants_by_id(single_item_merchants)
  end

  def extract_single_item_merchants(all_merchant_ids)
    all_merchant_ids.reject do |merchant_id|
      all_merchant_ids.count(merchant_id) > 1
    end
  end

  def merchants_with_only_one_item_registered_in_month(month)
    @merchants.collection.find_all do |merchant|
      merchant.items.count == 1 && merchant.created_at.strftime('%B') == month
    end
  end

  def revenue_by_merchant(merchant_id)
    all_inv_by_merchant = @invoice_repo.find_all_by_merchant_id(merchant_id)
    totals = all_inv_by_merchant.map do |invoice|
      invoice.total
    end
    totals.reduce(:+)
  end

  def merchants_ranked_by_revenue
    merchants = @merchants.all
    revenue = {}
    merchants.each do |merchant|
      revenue[merchant] = total_revenue_by_merchant_id(merchant.id)
    end
    revenue = revenue.sort_by{|key, val| val}.reverse.to_h
    revenue.keys
  end

  def most_sold_item_for_merchant(merchant_id)
    all_invoices = @invoice_repo.find_all_by_merchant_id(merchant_id)
    paid_invoice_ids = all_paid_invoices(all_invoices).compact
    all_invoice_items =
      @invoice_items.find_by_multiple_invoice_ids(paid_invoice_ids).flatten
    top_invoice_item_by_quantity =
      get_top_invoice_item_by_quantity(all_invoice_items)

    all_top_invoice_items = all_invoice_items.find_all do |invoice_item|
      invoice_item.quantity == top_invoice_item_by_quantity.quantity
    end

    all_top_invoice_items.map do |invoice_item|
      @item_repo.find_by_id(invoice_item.item_id)
    end
  end

  def all_paid_invoices(all_invoices)
    all_invoices.map do |invoice|
      invoice.id if invoice.is_paid_in_full?
    end
  end

  def get_top_invoice_item_by_quantity(all_invoice_items)
    all_invoice_items.max_by do |invoice_item|
      invoice_item.quantity
    end
  end

  def best_item_for_merchant(merchant_id)
    all_invoices = @invoice_repo.find_all_by_merchant_id(merchant_id)
    paid_invoice_ids = all_paid_invoices(all_invoices).compact
    all_invoice_items =
      @invoice_items.find_by_multiple_invoice_ids(paid_invoice_ids).flatten
    top_invoice_item_by_revenue = all_invoice_items.max_by do |invoice_item|
      invoice_item.quantity * invoice_item.unit_price
    end
    all_top_invoice_items = all_invoice_items.find_all do |invoice_item|
      invoice_item.quantity * invoice_item.unit_price ==
        top_invoice_item_by_revenue.quantity * top_invoice_item_by_revenue.unit_price
    end
    item = all_top_invoice_items.map do |invoice_item|
      @item_repo.find_by_id(invoice_item.item_id)
    end
    item.first
  end
end
