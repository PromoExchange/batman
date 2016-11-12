class DistributorCentral::FullProduct
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

  base_uri "#{ENV['DISTRIBUTOR_CENTRAL_URL']}/resources/xml/item_information.cfm"

  def self.retrieve(supplier_item_guid)
    uri = "#{base_uri}?acctwebguid=#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}&supplieritemguid=#{supplier_item_guid}"
    response = get(uri)

    doc = Nokogiri::XML(response.body)
    DistributorCentral::FullProduct.new(
      acct_guid: doc.xpath('product/maininfo/ACCTGUID').text,
      add_info: doc.xpath('product/maininfo/ADDINFO').text,
      company_name: doc.xpath('product/maininfo/COMPANYNAME').text,
      country_name: doc.xpath('product/maininfo/COUNTRYNAME').text,
      description: doc.xpath('product/maininfo/DESCRIPTION').text,
      display_name: doc.xpath('product/maininfo/DISPLAYNAME').text,
      display_num: doc.xpath('product/maininfo/DISPLAYNO').text,
      increment: doc.xpath('product/maininfo/INCREMENT').text,
      isrush: doc.xpath('product/maininfo/ISRUSH').text,
      last_update_date: doc.xpath('product/maininfo/LASTUPDATEDDATE').text,
      name: doc.xpath('product/maininfo/NAME').text,
      num: doc.xpath('product/maininfo/NO').text,
      production_time: doc.xpath('product/maininfo/PRODUCTIONTIME').text,
      size: doc.xpath('product/maininfo/SIZE').text,
      supplier_item_guid: doc.xpath('product/maininfo/SUPPLIERITEMGUID').text,
      weight: doc.xpath('product/maininfo/WEIGHT').text,
      prices: doc.xpath('product/pricing').map { |price| DistributorCentral::Price.extract(price) },
      options: doc.xpath('product/options/option').map { |option| DistributorCentral::Option.extract(option) },
      categories: doc.xpath('product/PRODUCTCATEGORIES/PRODUCTCATEGORY').map do |option|
        DistributorCentral::ItemCategory.extract(option)
      end,
      imprint_areas: doc.xpath('product/IMPRINTAREA').map do |imprint_area|
        DistributorCentral::ImprintArea.extract(imprint_area)
      end,
      packaging: DistributorCentral::Packaging.extract(doc.xpath('product/PACKAGING'))
    )
  rescue e
    Rails.logger.error("PLOAD: Failed to load product #{supplier_item_guid} Reason: #{e.message}")
  end

  def valid?
    prices.count > 0 && categories.count > 0 && options.count > 0
  end
end
