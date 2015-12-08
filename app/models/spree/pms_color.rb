class Spree::PmsColor < Spree::Base
  has_and_belongs_to_many :suppliers
  validates :name, presence: true

  def self.to_csv
    attributes = %w(name pantone hex display_name)

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |option_mapping|
        csv << attributes.map { |attr| option_mapping.send(attr) }
      end
    end
  end
end
