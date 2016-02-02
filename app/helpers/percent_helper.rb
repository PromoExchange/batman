module PercentHelper
  def percentage_display(value)
    return '-' if value.blank?
    number_with_precision(
      value.to_f * 100,
      strip_insignificant_zeros: true,
      precision: 3
    )
  end
end
