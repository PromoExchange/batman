class Spree::Upcharge < Spree::Base
  belongs_to :related, polymorphic: true
  has_one :upcharge_type

  validates :upcharge_type_id, presence: true
  validates :related_type, presence: true
  validates :related_id, presence: true
  validates :value, presence: true
end
