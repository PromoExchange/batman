class Spree::OptionMapping < Spree::Base
  validates :dc_acct_num, presence: true
  validates :dc_name, presence: true

  def self.to_csv
    attributes = %w(dc_acct_num dc_name px_name do_not_save)

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.find_each do |option_mapping|
        csv << attributes.map { |attr| option_mapping.send(attr) }
      end
    end
  end
end
