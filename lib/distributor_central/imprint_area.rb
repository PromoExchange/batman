class DistributorCentral::ImprintArea
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name,
    :description,
    :required,
    :max_lines,
    :height,
    :length,
    :radius,
    :width,
    :instructions,
    :decoration_limit,
    :options

  def self.extract(node)
    rec = DistributorCentral::ImprintArea.new
    rec.name = node.xpath('ImprintAreaName').text
    rec.description = node.xpath('ImprintAreaDescription').text
    rec.required = node.xpath('Required').text
    rec.max_lines = node.xpath('ImprintMaxLines').text
    rec.height = node.xpath('ImprintHeight').text
    rec.length = node.xpath('ImprintLength').text
    rec.radius = node.xpath('ImprintRadius').text
    rec.width = node.xpath('ImprintWidth').text
    rec.instructions = node.xpath('ImprintAreaInstructions').text
    rec.decoration_limit = node.xpath('DecorationLimit').text
    rec.options = []
    node.xpath('OPTIONS').each do |option|
      rec.options << option.xpath('OPTIONGUID').text
    end
    rec
  end
end
