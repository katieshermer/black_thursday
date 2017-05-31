require 'simplecov'
SimpleCov.start
require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/item.rb'
require 'pry'

class ItemTest < Minitest::Test

  def test_item_exists
    item = Item.new({:id => nil})
    assert_instance_of Item, item
  end

  def test_item_has_an_id
    item = Item.new({:id => 13})
    assert_equal item.id, 13
  end

  def test_item_has_a_name
    item = Item.new({:name => "scarf"})
    assert_equal item.name, "scarf"
  end

  def test_item_has_a_description
    item = Item.new({:description => "blue and fuzzy"})
    assert_equal item.description, "blue and fuzzy"
  end

  def test_item_has_a_price
    item = Item.new({:unit_price => BigDecimal.new(10.99,4)})
    assert_equal item.unit_price, 0.1099e2
  end

  def test_item_has_a_merchant_id
    item = Item.new({:merchant_id => 145})
    assert_equal item.merchant_id, 145
  end

  def test_item_has_a_create_date
    time = Time.now
    item = Item.new({:created_at => time})
    assert_equal item.created_at, time
  end

  def test_item_has_an_update_date
    time = Time.now
    item = Item.new({:updated_at => time})
    assert_equal item.updated_at, time
  end

  def test_item_price_in_dollars
    item = Item.new({:unit_price => BigDecimal.new(10.99,4)})
    assert_equal item.unit_price_to_dollars, 10.99
  end

end
