class DistributorCentral::Price < DistributorCentral::Base
  attr_accessor :code,
    :issetup,
    :net,
    :qty,
    :retail,
    :unit_of_measure

  def self.extract(node)
    DistributorCentral::Price.new(
      code: node.xpath('CODE').text,
      issetup: node.xpath('ISSETUP').text,
      net: node.xpath('NET').text,
      qty: node.xpath('QTY').text,
      retail: node.xpath('RETAIL').text,
      unit_of_measure: node.xpath('UNITOFMEASURE').text
    )
  end
end
