Spree::OptionValue.class_eval do
  has_and_belongs_to_many :suppliers
end
