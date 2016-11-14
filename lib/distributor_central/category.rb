class DistributorCentral::Category < DistributorCentral::Base
  base_uri "#{ENV['DISTRIBUTOR_CENTRAL_URL']}/resources/xml/category_list.cfm"

  attr_accessor :guid, :name, :children

  def self.category_tree
    response = get(
      "#{base_uri}?acctwebguid=#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}&"\
      "CatalogGUID=#{ENV['DISTRIBUTOR_CENTRAL_ALL_PRODUCT_CATALOG_ID']}"
    )

    raise HTTParty::ResponseError('HTTP Failure') unless response.success?

    Nokogiri::XML(response.body).xpath('MASTERCATEGORIES/MASTERCATEGORY').map do |item|
      DistributorCentral::Category.new(
        name: item.xpath('MASTERCATEGORYNAME').text,
        guid: item.xpath('MASTERCATEGORYGUID').text,
        children: item.xpath('PRODUCTCATEGORIES/PRODUCTCATEGORY').map do |child|
          DistributorCentral::Category.new(
            name: child.xpath('PRODUCTCATEGORYNAME').text,
            guid: child.xpath('PRODUCTCATEGORYGUID').text,
            children: nil
          )
        end
      )
    end
  rescue e
    Rails.logger.error("PLOAD: Failed to get category list, Reason: #{e.message}")
    []
  end
end
