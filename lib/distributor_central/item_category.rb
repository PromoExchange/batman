class DistributorCentral::ItemCategory
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :guid, :name

  def self.extract(node)
    DistributorCentral::ItemCategory.new(
      guid: node.xpath('PRODUCTCATEGORYGUID').text,
      name: node.xpath('PRODUCTCATEGORYNAME').text
    )
  end
end
