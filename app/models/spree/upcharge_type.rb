class Spree::UpchargeType < Spree::Base
  TYPES = [
    :pms_color_match,
    :ink_change,
    :no_under_over,
    :less_than_minimum,
    :setup,
    :run,
    :additional_location_run,
    :additional_color_run,
    :rush
  ].freeze

  has_many :upcharges
  validates :name, presence: true
  validates :name, inclusion: { in: TYPES.map(&:to_s) }
end
