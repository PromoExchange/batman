class Spree::DC::OptionDetail
  include HTTParty
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :supplier_item_num,
    :name,
    :description,
    :chargable,
    :image_available,
    :optional,
    :max_option_qty,
    :free_options,
    :supplier_display_num,
    :supplier_display_name,
    :order_question,
    :min_option_qty,
    :min_main_qty,
    :max_main_qty,
    :increment,
    :pricing,
    :option_choices

  base_uri 'http://www.distributorcentral.com/resources/xml/item_option.cfm'

  # http://www.distributorcentral.com/resources/xml/item_option.cfm?acctwebguid=F616D9EB-87B9-4B32-9275-0488A733C719&optionguid=EAADA3DE-39B2-4E38-AD52-5966EBAF881D

  def self.retrieve(option_guid)
    response = get("#{base_uri}?acctwebguid=#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}&optionguid=#{option_guid}")
    doc = Nokogiri::XML(response.body)

    option_rec = Spree::DC::OptionDetail.new
    option_rec.supplier_item_num = doc.xpath('option/maininfo/SuplItemOptionNo').text
    option_rec.name = doc.xpath('option/maininfo/OptionName').text
    option_rec.description = doc.xpath('option/maininfo/OptionDescription').text
    option_rec.chargable = doc.xpath('option/maininfo/Chargable').text
    option_rec.image_available = doc.xpath('option/maininfo/ImageAvailable').text
    option_rec.optional = doc.xpath('option/maininfo/Optional').text
    option_rec.max_option_qty = doc.xpath('option/maininfo/MaxOptionQty').text
    option_rec.free_options = doc.xpath('option/maininfo/FreeOptions').text
    option_rec.supplier_display_num = doc.xpath('option/maininfo/SuplItemOptionDisplayNo').text
    option_rec.supplier_display_name = doc.xpath('option/maininfo/SuplItemOptionDisplayName').text
    option_rec.order_question = doc.xpath('option/maininfo/OrderQuestion').text
    option_rec.min_option_qty = doc.xpath('option/maininfo/MinOptionQty').text
    option_rec.min_main_qty = doc.xpath('option/maininfo/MinMainQty').text
    option_rec.max_main_qty = doc.xpath('option/maininfo/MaxMainQty').text
    option_rec.increment = doc.xpath('option/maininfo/Increment').text

    option_rec.pricing = []
    doc.xpath('option/pricing').each do |price|
      option_rec.pricing << Spree::DC::Price.extract(price)
    end

    option_rec.option_choices = []
    doc.xpath('option/choices/choice').each do |choice|
      option_rec.option_choices << Spree::DC::OptionChoice.extract(choice)
    end
    option_rec
  end
end
