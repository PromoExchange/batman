class DistributorCentral::OptionDetail
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

  base_uri "#{ENV['DISTRIBUTOR_CENTRAL_URL']}/resources/xml/item_option.cfm"

  def self.retrieve(option_guid)
    response = get("#{base_uri}?acctwebguid=#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}&optionguid=#{option_guid}")
    doc = Nokogiri::XML(response.body)

    Spree::DcOptionDetail.new(
      supplier_item_num: doc.xpath('option/maininfo/SuplItemOptionNo').text,
      name: doc.xpath('option/maininfo/OptionName').text,
      description: doc.xpath('option/maininfo/OptionDescription').text,
      chargable: doc.xpath('option/maininfo/Chargable').text,
      image_available: doc.xpath('option/maininfo/ImageAvailable').text,
      optional: doc.xpath('option/maininfo/Optional').text,
      max_option_qty: doc.xpath('option/maininfo/MaxOptionQty').text,
      free_options: doc.xpath('option/maininfo/FreeOptions').text,
      supplier_display_num: doc.xpath('option/maininfo/SuplItemOptionDisplayNo').text,
      supplier_display_name: doc.xpath('option/maininfo/SuplItemOptionDisplayName').text,
      order_question: doc.xpath('option/maininfo/OrderQuestion').text,
      min_option_qty: doc.xpath('option/maininfo/MinOptionQty').text,
      min_main_qty: doc.xpath('option/maininfo/MinMainQty').text,
      max_main_qty: doc.xpath('option/maininfo/MaxMainQty').text,
      increment: doc.xpath('option/maininfo/Increment').text,
      pricing: doc.xpath('option/pricing').map { |price| DistributorCentral::Price.extract(price) },
      option_choices: doc.xpath('option/choices/choice').map do |choice|
        DistributorCentral::OptionChoice.extract(choice)
      end
    )
  end
end
