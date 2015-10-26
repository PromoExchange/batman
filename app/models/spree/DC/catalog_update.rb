class Spree::DC::CatalogUpdate
  include HTTParty
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :acct_guid,
    :date_added_search,
    :company_name,
    :create_date,
    :item_action,
    :item_name,
    :last_update_date,
    :supplier_display_name,
    :supplier_display_num,
    :supplier_item_num,
    :supplier_item_guid

  base_uri 'http://www.distributorcentral.com/resources/xml/change_list.cfm'

  # http://www.distributorcentral.com/resources/xml/change_list.cfm?acctwebguid=F616D9EB-87B9-4B32-9275-0488A733C719&startdate=01-11-2015

  def self.retrieve_update_list(start_date)
    date = start_date.strftime('%m-%d-%Y')

    response = get("#{base_uri}?acctwebguid=#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}&startdate=#{date}")
    doc = Nokogiri::XML(response.body)

    coll = []

    doc.xpath('PRODUCTS/PRODUCT').each do |update|
      rec = Spree::DC::CatalogUpdate.new
      rec.acct_guid = update.xpath('ACCTGUID').text
      rec.date_added_search = update.xpath('ADDEDTOSEARCHDATE').text
      rec.company_name = update.xpath('COMPANYNAME').text
      rec.create_date = update.xpath('CREATEDATE').text
      rec.item_action = update.xpath('ITEMACTION').text
      rec.item_name = update.xpath('ITEMNAME').text
      rec.last_update_date = update.xpath('LASTUPDATEDDATE').text
      rec.supplier_display_name = update.xpath('SUPLDISPLAYNAME').text
      rec.supplier_display_num = update.xpath('SUPLDISPLAYNO').text
      rec.supplier_item_num = update.xpath('SUPLITEMNO').text
      rec.supplier_item_guid = update.xpath('SUPPLIERITEMGUID').text
      coll << rec
    end
    coll
  end
end
