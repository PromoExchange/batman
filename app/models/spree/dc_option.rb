# Distributor Central
class Spree::DcOption
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name,
    :guid,
    :type,
    :choices

  def self.extract(node)
    rec = Spree::DcOption.new
    rec.name = node.xpath('OPTIONNAME').text
    rec.guid = node.xpath('OPTIONGUID').text
    rec.type = node.xpath('OPTIONTYPE').text

    rec.choices = []
    node.xpath('ITEMOPTIONCHOICENAME').each do |choice_name|
      rec.choices << choice_name.text
    end
    rec
  end
end
