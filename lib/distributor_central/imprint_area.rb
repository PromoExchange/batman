class DistributorCentral::ImprintArea < DistributorCentral::Base
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
    DistributorCentral::ImprintArea.new(
      name: node.xpath('ImprintAreaName').text,
      description: node.xpath('ImprintAreaDescription').text,
      required: node.xpath('Required').text,
      max_lines: node.xpath('ImprintMaxLines').text,
      height: node.xpath('ImprintHeight').text,
      length: node.xpath('ImprintLength').text,
      radius: node.xpath('ImprintRadius').text,
      width: node.xpath('ImprintWidth').text,
      instructions: node.xpath('ImprintAreaInstructions').text,
      decoration_limit: node.xpath('DecorationLimit').text,
      options: node.xpath('OPTIONS').map { |option| option.xpath('OPTIONGUID').text }
    )
  end
end
