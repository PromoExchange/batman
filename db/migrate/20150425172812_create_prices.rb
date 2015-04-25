class CreatePrices < ActiveRecord::Migration
  def change
    create_table :prices do |t|
      t.monetize :value ,null: false
      t.string :pricetype, null: false
      t.timestamps null: false
    end
  end
end
