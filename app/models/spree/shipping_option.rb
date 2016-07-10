class Spree::ShippingOption < ActiveRecord::Base
  belongs_to :quote

  # TODO: Should fixed be part of this enum?
  OPTION = {
    ups_ground: 1,
    ups_3day_select: 2,
    ups_second_day_air: 3,
    ups_next_day_air_saver: 4,
    ups_next_day_air_early_am: 5,
    ups_next_day_air: 6
  }.freeze

  validates :name, presence: true
  validates :delivery_date, presence: true
  validates :delivery_days, presence: true
  validates :shipping_option, presence: true
  validates :shipping_cost, presence: true
  validates :quote_id, presence: true
end
