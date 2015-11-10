class Spree::DC::Packaging
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :orig_zip,
    :quantity,
    :dimensions,
    :weight

  def self.extract(node)
    rec = Spree::DC::Packaging.new
    rec.orig_zip = node.xpath('ORIGZIP').text
    rec.quantity = node.xpath('QTY').text
    rec.weight = node.xpath('WEIGHT').text
    rec
  end
end
