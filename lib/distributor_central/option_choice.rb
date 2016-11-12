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
    rec = Spree::DcOptionChoice.new
    rec.guid = node.xpath('maininfo/ItemOptionChoiceGUID').text
    rec.name = node.xpath('maininfo/ItemOptionChoiceName').text
    rec.description = node.xpath('maininfo/ItemOptionDescription').text
    rec.hex_num = node.xpath('maininfo/HexNo').text
    rec.image_available = node.xpath('maininfo/ImageAvailable').text
    rec.use_hex = node.xpath('maininfo/UseHex').text
    rec.num = node.xpath('maininfo/SupplierItemOptionChoiceNo').text
    rec.display_num = node.xpath('maininfo/SupplierItemOptionChoiceDisplayNo').text
    rec.display_name = node.xpath('maininfo/SupplierItemOptionChoiceDisplayName').text
    rec.min_main_qty = node.xpath('maininfo/MinMainQty').text
    rec.max_main_qty = node.xpath('maininfo/MaxMainQty').text
    rec.min_choice_qty = node.xpath('maininfo/MinChoiceQty').text
    rec.max_choice_qty = node.xpath('maininfo/MaxChoiceQty').text
    rec.increment = node.xpath('maininfo/Increment').text
    rec
  end
end
