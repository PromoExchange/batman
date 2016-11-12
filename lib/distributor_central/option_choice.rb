class DistributorCentral::OptionChoice
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :guid,
    :name,
    :description,
    :hex_num,
    :image_available,
    :use_hex,
    :num,
    :display_num,
    :display_name,
    :min_main_qty,
    :max_main_qty,
    :min_choice_qty,
    :max_choice_qty,
    :increment

  def self.extract(node)
    DistributorCentral::OptionChoice.new(
      guid: node.xpath('maininfo/ItemOptionChoiceGUID').text,
      name: node.xpath('maininfo/ItemOptionChoiceName').text,
      description: node.xpath('maininfo/ItemOptionDescription').text,
      hex_num: node.xpath('maininfo/HexNo').text,
      image_available: node.xpath('maininfo/ImageAvailable').text,
      use_hex: node.xpath('maininfo/UseHex').text,
      num: node.xpath('maininfo/SupplierItemOptionChoiceNo').text,
      display_num: node.xpath('maininfo/SupplierItemOptionChoiceDisplayNo').text,
      display_name: node.xpath('maininfo/SupplierItemOptionChoiceDisplayName').text,
      min_main_qty: node.xpath('maininfo/MinMainQty').text,
      max_main_qty: node.xpath('maininfo/MaxMainQty').text,
      min_choice_qty: node.xpath('maininfo/MinChoiceQty').text,
      max_choice_qty: node.xpath('maininfo/MaxChoiceQty').text,
      increment: node.xpath('maininfo/Increment').text
    )
  end
end
