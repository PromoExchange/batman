class Spree::Upcharge < Spree::OptionValuesProduct
  VALUE_TYPES = %w(money percent).freeze
  validates :value_type, inclusion: { in: VALUE_TYPES }
end
