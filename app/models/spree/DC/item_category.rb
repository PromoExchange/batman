class Spree::DC::ItemCategory
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :guid, :name

  def self.extract(node)
    rec = Spree::DC::ItemCategory.new
    rec.guid = node.xpath('PRODUCTCATEGORYGUID').text
    rec.name = node.xpath('PRODUCTCATEGORYNAME').text
    rec
  end
end
