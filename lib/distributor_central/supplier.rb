class DistributorCentral::Supplier < DistributorCentral::Base
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

  base_uri "#{ENV['DISTRIBUTOR_CENTRAL_URL']}//resources/xml/supplier_list.cfm"

  def self.supplier_list
    response = get("#{base_uri}?acctwebguid=#{ENV['DISTRIBUTOR_CENTRAL_WEBACCTID']}")
    raise HTTParty::ResponseError('HTTP Failure') unless response.success?

    Nokogiri::XML(response.body).xpath('//SUPPLIER').map do |item|
      DistributorCentral::Supplier.new(
        acct_guid: item.xpath('ACCTGUID').text,
        add1: item.xpath('ADD1').text,
        add2: item.xpath('ADD2').text,
        city: item.xpath('CITY').text,
        company_name: item.xpath('COMPANYNAME').text,
        dc_acct_num: item.xpath('DCACCTNO').text,
        email: item.xpath('EMAIL').text,
        fax: item.xpath('FAX').text,
        phone: item.xpath('PHONE').text,
        state: item.xpath('ST').text,
        url: item.xpath('URL').text,
        zipcode: item.xpath('ZIP').text
      )
    end
  rescue => e
    Rails.logger.error("DC: Failed to get supplier: #{e.message}")
    []
  end

  def persisted?
    false
  end
end
