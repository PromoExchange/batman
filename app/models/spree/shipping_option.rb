class Spree::ShippingOption < ActiveRecord::Base
  belongs_to :quote

  OPTION = {
    ups_ground: 1,
    ups_3day_select: 2,
    ups_second_day_air: 3,
    ups_next_day_air_saver: 4,
    ups_next_day_air_early_am: 5,
    ups_next_day_air: 6,
    fixed_price_per_item: 7,
    fixed_price_total: 8
  }.freeze

  validates :name, presence: true
  validates :delivery_date, presence: true
  validates :delivery_days, presence: true
  # TODO: Shorten these to option and cost
  validates :shipping_option, presence: true
  validates :shipping_option, inclusion: { in: Spree::ShippingOption::OPTION.values }
  validates :shipping_cost, presence: true
  validates :quote_id, presence: true
end
