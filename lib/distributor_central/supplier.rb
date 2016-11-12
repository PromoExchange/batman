class DistributorCentral::Supplier
  include HTTParty
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  base_uri 'http://www.distributorcentral.com/resources/xml/supplier_list.cfm'

  attr_accessor :acct_guid,
    :add1,
    :add2,
    :city,
    :company_name,
    :dc_acct_num,
    :email,
    :fax,
    :phone,
    :state,
    :url,
    :zipcode

  def self.supplier_list
    response = get("#{base_uri}?acctwebguid=#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}")
    coll = []
    return coll unless response.success?
    doc = Nokogiri::XML(response.body)

    doc.xpath('//SUPPLIER').each do |item|
      rec = Spree::DcSupplier.new
      rec.acct_guid = item.xpath('ACCTGUID').text
      rec.add1 = item.xpath('ADD1').text
      rec.add2 = item.xpath('ADD2').text
      rec.city = item.xpath('CITY').text
      rec.company_name = item.xpath('COMPANYNAME').text
      rec.dc_acct_num = item.xpath('DCACCTNO').text
      rec.email = item.xpath('EMAIL').text
      rec.fax = item.xpath('FAX').text
      rec.phone = item.xpath('PHONE').text
      rec.state = item.xpath('ST').text
      rec.url = item.xpath('URL').text
      rec.zipcode = item.xpath('ZIP').text
      coll << rec
    end
    coll
  rescue
    return []
  end

  def persisted?
    false
  end
end
