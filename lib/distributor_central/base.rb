class DistributorCentral::Base
  include HTTParty
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize(params)
    params.each { |k, v| send("#{k}=", v) }
  end

  def persisted?
    false
  end
end
