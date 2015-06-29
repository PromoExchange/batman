class CreateJoinTablePmsAuction < ActiveRecord::Migration
  def change
    create_join_table :auctions, :pms_colors , table_name: 'spree_auctions_pms_colors' do |t|
      t.index :auction_id
      t.index :pms_color_id
    end
  end
end
