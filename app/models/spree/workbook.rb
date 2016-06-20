class Spree::Workbook
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :fields
  attr_reader :messages

  def fields
    @fields ||= {}
  end

  def messages
    @messages ||= []
  end
end
