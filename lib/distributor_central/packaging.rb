class DistributorCentral::Packaging
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :orig_zip,
    :quantity,
    :dimensions,
    :weight

  def self.extract(node)
    DistributorCentral::Packaging.new(
      orig_zip: node.xpath('ORIGZIP').text,
      quantity: node.xpath('QTY').text,
      weight: node.xpath('WEIGHT').text
    )
  end
end
