# Distributor Central
class Spree::DcImage
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :image

  def self.retrieve(supplier_item_guid)
    open(URI.parse("http://www.distributorcentral.com/resources/productimage.cfm?Prod=#{supplier_item_guid}&size=large"))
  end
end
