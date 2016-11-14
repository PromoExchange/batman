class DistributorCentral::Option < DistributorCentral::Base
  attr_accessor :name,
    :guid,
    :type,
    :choices

  def self.extract(node)
    DistributorCentral::Option.new(
      name: node.xpath('OPTIONNAME').text,
      guid: node.xpath('OPTIONGUID').text,
      type: node.xpath('OPTIONTYPE').text,
      choices: node.xpath('ITEMOPTIONCHOICENAME').map(&:text)
    )
  end
end
