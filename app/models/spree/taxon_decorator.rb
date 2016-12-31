Spree::Taxon.class_eval do
  has_and_belongs_to_many :option_values
  has_many :images, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: 'Spree::Image'
end
