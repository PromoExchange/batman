class Spree::DC::FullProduct
  include HTTParty
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :acct_guid,
    :add_info,
    :company_name,
    :country_name,
    :description,
    :display_name,
    :display_num,
    :increment,
    :isrush,
    :last_update_date,
    :name,
    :num,
    :production_time,
    :size,
    :supplier_item_guid,
    :weight,
    :prices,
    :options,
    :categories,
    :imprint_areas,
    :packaging

  base_uri 'http://www.distributorcentral.com/resources/xml/item_information.cfm'

  # http://www.distributorcentral.com/resources/xml/item_information.cfm?acctwebguid=F616D9EB-87B9-4B32-9275-0488A733C719&supplieritemguid=A2A4B3F2-9FD2-43DA-BCAF-A83E29AA3EF8

  def self.retrieve(supplier_item_guid)
    uri = "#{base_uri}?acctwebguid="\
          "#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}&"\
          "supplieritemguid=#{supplier_item_guid}"
    response = get(uri)
    doc = Nokogiri::XML(response.body)

    product_rec = Spree::DC::FullProduct.new
    product_rec.acct_guid = doc.xpath('product/maininfo/ACCTGUID').text
    product_rec.add_info = doc.xpath('product/maininfo/ADDINFO').text
    product_rec.company_name = doc.xpath('product/maininfo/COMPANYNAME').text
    product_rec.country_name = doc.xpath('product/maininfo/COUNTRYNAME').text
    product_rec.description = doc.xpath('product/maininfo/DESCRIPTION').text
    product_rec.display_name = doc.xpath('product/maininfo/DISPLAYNAME').text
    product_rec.display_num = doc.xpath('product/maininfo/DISPLAYNO').text
    product_rec.increment = doc.xpath('product/maininfo/INCREMENT').text
    product_rec.isrush = doc.xpath('product/maininfo/ISRUSH').text
    product_rec.last_update_date = doc.xpath('product/maininfo/LASTUPDATEDDATE').text
    product_rec.name = doc.xpath('product/maininfo/NAME').text
    product_rec.num = doc.xpath('product/maininfo/NO').text
    product_rec.production_time = doc.xpath('product/maininfo/PRODUCTIONTIME').text
    product_rec.size = doc.xpath('product/maininfo/SIZE').text
    product_rec.supplier_item_guid = doc.xpath('product/maininfo/SUPPLIERITEMGUID').text
    product_rec.weight = doc.xpath('product/maininfo/WEIGHT').text

    product_rec.prices = []
    doc.xpath('product/pricing').each do |dc_price|
      product_rec.prices << Spree::DC::Price.extract(dc_price)
    end

    product_rec.options = []
    doc.xpath('product/option').each do |option|
      product_rec.options << Spree::DC::Option.extract(option)
    end

    product_rec.categories = []
    doc.xpath('product/PRODUCTCATEGORY').each do |option|
      product_rec.categories << Spree::DC::ItemCategory.extract(option)
    end

    product_rec.imprint_areas = []
    doc.xpath('product/IMPRINTAREA').each do |imprint_area|
      product_rec.imprint_areas << Spree::DC::ImprintArea.extract(imprint_area)
    end

    product_rec.packaging = Spree::DC::Packaging.extract(doc.xpath('product/PACKAGING'))

    product_rec
  rescue StandardError => e
    Rails.logger.error("PLOAD: Failed to load product #{supplier_item_guid} Reason: #{e.message}")
  end
end
