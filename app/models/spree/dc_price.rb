# Distributor Central
class Spree::DcPrice
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :code,
    :issetup,
    :net,
    :qty,
    :retail,
    :unit_of_measure

  def self.extract(node)
    rec = Spree::DcPrice.new
    rec.code = node.xpath('CODE').text
    rec.issetup = node.xpath('ISSETUP').text
    rec.net = node.xpath('NET').text
    rec.qty = node.xpath('QTY').text
    rec.retail = node.xpath('RETAIL').text
    rec.unit_of_measure = node.xpath('UNITOFMEASURE').text
    rec
  end
end
