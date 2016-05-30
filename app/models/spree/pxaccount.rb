class Spree::Pxaccount
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize(user)
    @errors = ActiveModel::Errors.new(self)
    populate(user)
  end

  def populate(user)
    user = Spree::User.find(user.id)

    return if user.nil?
    instance_variable_set(:@email, user.email)
    instance_variable_set(:@password, '')
    instance_variable_set(:@password_confirmation, '')
    instance_variable_set(:@ship_address, Spree::Pxaddress.build_address(user, :ship))
    instance_variable_set(:@bill_address, Spree::Pxaddress.build_address(user, :bill))
  end

  attr_accessor :email,
    :password,
    :password_confirmation,
    :ship_address,
    :bill_address

  def persisted?
    false
  end
end
