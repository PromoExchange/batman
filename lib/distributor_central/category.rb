class DistributorCentral::Category
  include HTTParty
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  base_uri 'http://www.distributorcentral.com/resources/xml/category_list.cfm'

  attr_accessor :guid, :name, :children

  def self.category_tree
    catalog_guid = ENV['DISTRIBUTOR_CENTRAL_ALL_PRODUCT_CATALOG_ID']
    Rails.logger.info("PLOAD: Category Tree request: #{base_uri}?"\
                      "acctwebguid=#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}&"\
                      "CatalogGUID=#{catalog_guid}")
    response = get("#{base_uri}?acctwebguid=#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}&CatalogGUID=#{catalog_guid}")
    coll = []
    return coll unless response.success?
    doc = Nokogiri::XML(response.body)

    doc.xpath('MASTERCATEGORIES/MASTERCATEGORY').each do |item|
      rec = Spree::DcCategory.new
      rec.name = item.xpath('MASTERCATEGORYNAME').text
      rec.guid = item.xpath('MASTERCATEGORYGUID').text
      rec.children = []
      item.xpath('PRODUCTCATEGORIES/PRODUCTCATEGORY').each do |child|
        child_rec = Spree::DcCategory.new
        child_rec.name = child.xpath('PRODUCTCATEGORYNAME').text
        child_rec.guid = child.xpath('PRODUCTCATEGORYGUID').text
        child_rec.children = nil
        rec.children << child_rec
      end
      coll << rec
    end
    coll
  rescue StandardError => e
    Rails.logger.error("PLOAD: Failed to get category list, Reason: #{e.message}")
    []
  end
end
