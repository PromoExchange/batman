class CreateMarkup < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.table_exists? 'spree_markups'
      create_table :spree_markups do |t|
        t.integer :supplier_id, null: false
        t.decimal :markup, null: false
        t.boolean :eqp, null: false, default: false
        t.decimal :eqp_discount, null: false, default: 0.0
        t.boolean :live, null: false, default: true
        t.integer :company_store_id, null: false
      end
    end
  end
end
