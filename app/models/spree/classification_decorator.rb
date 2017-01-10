Spree::Classification.class_eval do
  delegate :images, to: :taxon
  delegate :name, to: :taxon
end
