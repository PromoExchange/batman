# Distributor Central
class Spree::DcImage
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :image

  def self.retrieve(supplier_item_guid)
    url = "http://www.distributorcentral.com/resources/productimage.cfm?Prod=#{supplier_item_guid}&size=large"
    open(URI.parse(url))
  end
end
