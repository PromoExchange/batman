module Spree
  class PmsColor < Spree::Base
    validates :name, presence: true
    validates :pantone , presence: true
  end
end
