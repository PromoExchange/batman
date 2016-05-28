class Spree::PmsColorsSupplier < Spree::Base
  belongs_to :supplier
  belongs_to :pms_color
  belongs_to :imprint_method

  validates :supplier_id, presence: true
  validates :pms_color_id, presence: true
  validates :imprint_method_id, presence: true

  def self.to_csv
    attributes = %w(factory imprint_method name display_name pantone hex)
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.find_each do |myrow|
        row = []
        factory = Spree::Supplier.find(myrow.supplier_id)
        imprint_method = Spree::ImprintMethod.find(myrow.imprint_method_id)
        pms_color = Spree::PmsColor.find(myrow.pms_color_id)
        row << factory.name
        row << imprint_method.name
        row << pms_color.name
        row << pms_color.display_name
        row << pms_color.pantone
        row << pms_color.hex
        csv << row
      end
    end
  end
end
