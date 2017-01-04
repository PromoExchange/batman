class Spree::Gooten::Price < Spree::Base
  self.table_name = 'spree_gooten_prices'

  belongs_to :company_store
  belongs_to :product
end
