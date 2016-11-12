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

  base_uri 'http://www.distributorcentral.com/resources/xml/item_choose.cfm'

  def self.product_list(factory_name)
    coll = []
    uri = "#{base_uri}?acctwebguid="\
          "#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}&"\
          "companyinfo=#{URI.encode factory_name}&MaxRows=0"
    response = get(uri)
    doc = Nokogiri::XML(response.body)

    num_products = doc.xpath('//totalresults').text

    (0..num_products.to_i).step(30) do |x|
      uri = "#{base_uri}?acctwebguid="\
            "#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}&"\
            "companyinfo=#{URI.encode factory_name}&MaxRows=30&StartRow=#{x + 1}"
      response = get(uri)
      doc = Nokogiri::XML(response.body)

      doc.xpath('products/product').each do |product|
        product_rec = Spree::DcBaseProduct.new
        product_rec.company_name = product.xpath('COMPANYNAME').text
        product_rec.item_name = product.xpath('ITEMNAME').text
        product_rec.max_retail = product.xpath('MAXRETAIL').text
        product_rec.min_qty = product.xpath('MINQTY').text
        product_rec.min_retail = product.xpath('MINRETAIL').text
        product_rec.production_time = product.xpath('PRODUCTIONTIME').text
        product_rec.rush_available = product.xpath('RUSHAVAILABLE').text
        product_rec.supplier_display_name = product.xpath('SUPLDISPLAYNAME').text
        product_rec.supplier_display_num = product.xpath('SUPLDISPLAYNO').text
        product_rec.supplier_item_num = product.xpath('SUPLITEMNO').text
        product_rec.supplier_item_guid = product.xpath('SUPPLIERITEMGUID').text
        coll << product_rec
      end
    end
    coll
  rescue StandardError => e
    Rails.logger.error("PLOAD: Failed to get product list for [#{factory_name}], Reason: #{e.message}")
    []
  end
end
