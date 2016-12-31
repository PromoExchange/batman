class Spree::CompanyStore < Spree::Base
  belongs_to :supplier, class_name: 'Spree::Supplier', inverse_of: :products
  belongs_to :buyer, class_name: 'Spree::User'
  has_many :markups, dependent: :destroy

  validates :buyer_id, presence: true
  validates :supplier_id, presence: true
  validates :slug, presence: true
  validates :name, presence: true
  validates :host, presence: true

  has_attached_file :logo, path: '/company_store/:id/:style/:basename.:extension'
  validates_attachment :logo, presence: true
  validates_attachment_content_type :logo,
    content_type: %w(image/jpeg image/png)

  accepts_nested_attributes_for :markups, allow_destroy: true, reject_if: ->(m) { m[:markup].blank? }

  def products
    Spree::Product.where(
      id: Spree::Classification.where(taxon: store_taxon).pluck(:product_id)
    )
  end

  def store_taxon
    Spree::Taxon.where(
      name: slug,
      taxonomy: Spree::Taxonomy.where(name: 'Stores').first_or_create
    ).first_or_create
  end

  def seller
    Rails.cache.fetch("#{cache_key}/seller", expires_in: 5.minutes) do
      Spree::User.find_by(email: ENV['SELLER_EMAIL'])
    end
  end

  def cache_key
    "#{model_name.cache_key}/#{id || 'new'}"
  end
end
