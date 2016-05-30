class Spree::Pxaddress
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :company,
    :firstname,
    :lastname,
    :address1,
    :address2,
    :city,
    :country,
    :country_id,
    :state_name,
    :state_id,
    :zipcode,
    :phone

  def initialize
    @errors = ActiveModel::Errors.new(self)
  end

  def self.build_address(user, address_type)
    new_address = Spree::Pxaddress.new
    address = address_type == :ship ? user.ship_address : user.bill_address

    return unless address

    fields = %w(company firstname lastname address1 address2 city state_name country state_id country_id zipcode phone)
    fields.each { |field| new_address.instance_variable_set("@#{field}", address.send(field)) }
    new_address
  end

  def persisted?
    false
  end
end
