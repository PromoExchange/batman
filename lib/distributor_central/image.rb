class DistributorCentral::Image
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :image

  def self.retrieve(supplier_item_guid)
    open(
      URI.parse("#{ENV['DISTRIBUTOR_CENTRAL_URL']}/resources/productimage.cfm?Prod=#{supplier_item_guid}&size=large")
    )
  end
end
