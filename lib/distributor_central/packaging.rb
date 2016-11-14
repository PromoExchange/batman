class DistributorCentral::Packaging < DistributorCentral::Base
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
