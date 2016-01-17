module PercentHelper
  def percentage_display(value)
    return '-' if value.to_f < 0.0001
    (value.to_f * 100).round(3)
  end
end
