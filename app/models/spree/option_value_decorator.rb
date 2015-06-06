Spree::OptionValue.class_eval do
  has_and_belongs_to_many :suppliers
  has_and_belongs_to_many :taxons

  scope :upgrades, -> {where("option_type_id = #{Spree::OptionType.find_by(name: :upcharge).id}")}
  scope :colors, -> {where("option_type_id = #{Spree::OptionType.find_by(name: :color).id}")}
end
