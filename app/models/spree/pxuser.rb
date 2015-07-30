class Spree::Pxuser
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize
    @errors = ActiveModel::Errors.new(self)
  end

  attr_accessor :first_name,
    :last_name,
    :company,
    :email_address,
    :password,
    :password_confirm,
    :password_confirm,
    :address_line1,
    :address_line2,
    :city,
    :state,
    :zipcode,
    :phonenumber,
    :asi_number,
    :buyer_seller,
    :errors

  def persisted?
    false
  end
end
