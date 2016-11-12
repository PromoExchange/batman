class DistributorCentral::CatalogUpdate
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

  base_uri "#{ENV['DISTRIBUTOR_CENTRAL_URL']}/resources/xml/change_list.cfm"

  def self.retrieve_update_list(start_date)
    date = start_date.strftime('%m-%d-%Y')
    response = get("#{base_uri}?acctwebguid=#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}&startdate=#{date}")

    Nokogiri::XML(response.body).xpath('PRODUCTS/PRODUCT').map do |update|
      DistributorCentral::CatalogUpdate.new(
        acct_guid: update.xpath('ACCTGUID').text,
        date_added_search: update.xpath('ADDEDTOSEARCHDATE').text,
        company_name: update.xpath('COMPANYNAME').text,
        create_date: update.xpath('CREATEDATE').text,
        item_action: update.xpath('ITEMACTION').text,
        item_name: update.xpath('ITEMNAME').text,
        last_update_date: update.xpath('LASTUPDATEDDATE').text,
        supplier_display_name: update.xpath('SUPLDISPLAYNAME').text,
        supplier_display_num: update.xpath('SUPLDISPLAYNO').text,
        supplier_item_num: update.xpath('SUPLITEMNO').text,
        supplier_item_guid: update.xpath('SUPPLIERITEMGUID').text
      )
    end
  end
end
