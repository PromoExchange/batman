class Spree::PmsColor < Spree::Base
  belongs_to :quote

  validates :name, presence: true
  validates :quote, presence: true
end
