module Spree
  class ImprintMethod < Spree::Base
    has_and_belongs_to_many :products
  end
end
