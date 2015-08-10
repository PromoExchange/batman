class Spree::Upcharge < Spree::Base
  belongs_to :upcharge_type

  validates :upcharge_type_id, presence: true
  validates :type, presence: true
  validates :related_id, presence: true
  validates :value, presence: true
end
