class Spree::Pxaddress
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize
    @errors = ActiveModel::Errors.new(self)
  end

  def self.build_address(user, address_type)
    new_address = Spree::Pxaddress.new

    if address_type == :ship
      address = user.ship_address
    else
      address = user.bill_address
    end

    fields = %w(
      company
      firstname
      lastname
      address1
      address2
      city
      state_name
      country
      state_id
      country_id
      zipcode
      phone
    )

    fields.each do |field|
      new_address.instance_variable_set("@#{field}", eval("address.#{field}"))
    end
    new_address
  end

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

  def persisted?
    false
  end
end
