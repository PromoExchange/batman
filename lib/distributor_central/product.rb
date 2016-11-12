class DistributorCentral::Product
  include HTTParty
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :company_name,
    :item_name,
    :max_retail,
    :min_qty,
    :min_retail,
    :production_time,
    :rush_available,
    :supplier_display_name,
    :supplier_display_num,
    :supplier_item_num,
    :supplier_item_guid

  base_uri "#{ENV['DISTRIBUTOR_CENTRAL_URL']}/resources/xml/item_choose.cfm"

  def self.product_list(factory_name)
    coll = []
    uri = "#{base_uri}?acctwebguid="\
          "#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}&"\
          "companyinfo=#{URI.encode(factory_name)}&MaxRows=0"

    (0..Nokogiri::XML(get(uri).body).xpath('//totalresults').text.to_i).step(30) do |x|
      uri = "#{base_uri}?acctwebguid="\
            "#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}&"\
            "companyinfo=#{URI.encode(factory_name)}&MaxRows=30&StartRow=#{x + 1}"

      coll.concat(Nokogiri::XML(get(uri).body).xpath('products/product').map do |product|
        DistributorCentral::Product.new(
          company_name: product.xpath('COMPANYNAME').text,
          item_name: product.xpath('ITEMNAME').text,
          max_retail: product.xpath('MAXRETAIL').text,
          min_qty: product.xpath('MINQTY').text,
          min_retail: product.xpath('MINRETAIL').text,
          production_time: product.xpath('PRODUCTIONTIME').text,
          rush_available: product.xpath('RUSHAVAILABLE').text,
          supplier_display_name: product.xpath('SUPLDISPLAYNAME').text,
          supplier_display_num: product.xpath('SUPLDISPLAYNO').text,
          supplier_item_num: product.xpath('SUPLITEMNO').text,
          supplier_item_guid: product.xpath('SUPPLIERITEMGUID').text
        )
      end)
    end

    coll
  rescue e
    Rails.logger.error("PLOAD: Failed to get product list for [#{factory_name}], Reason: #{e.message}")
    []
  end
end
