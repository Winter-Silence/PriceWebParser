class AddPeriodLowestPriceFieldToProduct < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :period_lowest_price, :integer
    Product.update_all(period_lowest_price: 60)
  end
end
