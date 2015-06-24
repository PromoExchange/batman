class AddPriceCodeToUpcharges < ActiveRecord::Migration
  def change
    add_column :spree_upcharges, :price_code, :string
  end
end
