module Spree
  class Supplier < Spree::Base
    belongs_to :address, class_name: 'Spree::Address', inverse_of: :suppliers
    has_many :products, class_name: 'Spree::Product', inverse_of: :supplier
    has_and_belongs_to_many :option_values

    validates :name, presence: true
  end
end
