require './test/test_helper'
require './lib/sales_engine'

class SalesEngineTest < Minitest::Test

  def test_it_exists_and_has_repos
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"})
    assert_instance_of ItemRepository, se.items
    assert_instance_of MerchantRepository, se.merchants
    assert_instance_of InvoiceRepository, se.invoice_repo
    assert_instance_of InvoiceItemRepository, se.invoice_items
    assert_instance_of TransactionRepository, se.transactions
    assert_instance_of CustomerRepository, se.customers
  end

  def test_items_can_searched_via_find_by_id
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"})
    items = se.items
    assert_instance_of Item, items.find_by_id(263395237)
  end

  def test_item_dot_merchant_returns_items_merchant
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    item = se.items.find_by_id(263395237)
    assert_instance_of Merchant, item.merchant
  end

  def test_items_can_searched_via_find_by_name
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    items = se.items
    assert_instance_of Item, items.find_by_name("510+ RealPush Icon Set")
  end

  def test_items_can_searched_via_find_all_by_price
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    items = se.items
    assert_equal 7, items.find_all_by_price(400.00).length
  end

  def test_items_can_searched_via_find_by_merchant_id
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    items = se.items
    assert_equal 1, items.find_all_by_merchant_id(12334141).length
  end

  def test_it_returns_empty_array_with_invalid_merchant_id
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    items = se.items
    assert_equal items.find_all_by_merchant_id("kwjalkdwja"), []
  end

  def test_merchant_customers_puts_array_of_all_customers
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    merchant = se.merchants.find_by_id(12335938)
    result = merchant.customers
    assert_instance_of Array, result
    assert_equal 16, result.length
  end

  def test_invoice_dot_items_puts_array_of_all_items
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    invoice = se.invoices.find_by_id(20)
    result = invoice.items
    assert_equal 5, result.length
    assert_instance_of Item, result[0]
  end

  def test_invoices_dot_transactions_puts_array_of_transactions
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    invoice = se.invoices.find_by_id(20)
    result = invoice.transactions
    assert_instance_of Array, result
    assert_equal 3, result.length
    assert_instance_of Transaction, result[0]
  end

  def test_invoices_can_find_customer
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    invoice = se.invoices.find_by_id(20)
    result = invoice.customer
    assert_instance_of Customer, result
    assert_equal "Sylvester", result.first_name
  end

  def test_find_all_transaction_invoices
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    transaction = se.transactions.find_by_id(40)
    result = transaction.invoice
    assert_instance_of Invoice, result
  end

  def test_find_all_customers_merchants
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    customer = se.customers.find_by_id(30)
    result = customer.merchants
    assert_instance_of Array, result
    assert_instance_of Merchant, result[0]
    assert_equal 5, result.length
    assert_equal "thepurplepenshop", result[4].name
  end

  def test_merchant_items
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    merchant = se.merchants.find_by_id(12334105)
    result = merchant.items
    assert_instance_of Array, result
    assert_instance_of Item, result.first
    assert_equal 3, result.count
    assert_equal "Vogue Paris Original Givenchy 2307", result.first.name
  end

  def test_item_merchant
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    item = se.items.find_by_id(263395237)
    result = item.merchant
    assert_instance_of Merchant, result
    assert_equal 12334141, result.id
  end

  def test_merchant_invoices
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    merchant = se.merchants.find_by_id(12334105)
    result = merchant.invoices
    assert_instance_of Array, result
    assert_equal 10, result.count
  end

  def test_invoice_merchant
    se = SalesEngine.from_csv({
      :items => "./data/items.csv",
      :merchants => "./data/merchants.csv",
      :invoices => "./data/invoices.csv",
      :invoice_items => "./data/invoice_items.csv",
      :transactions => "./data/transactions.csv",
      :customers => "./data/customers.csv"
      })
    invoice = se.invoice_repo.find_by_id(1)
    result = invoice.merchant
    assert_instance_of Merchant, result
    assert_equal 12335938, result.id
  end


end
