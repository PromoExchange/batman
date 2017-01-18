class Spree::CompanyStore < Spree::Base
  include Categories

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

  enum store_type: [:traditional, :hybrid, :gooten]

  def default_logo
    buyer.logos.first
  end

  def products(options = {})
    returned_products = Spree::Product.where(
      id: Spree::Classification.where(taxon: store_taxon).pluck(:product_id)
    ).to_a

    # 1. Get all products (no options)
    # 2. Get products for a given category
    # 3. Get products for a given category and quality
    if options[:category].present?
      returned_products.reject! do |product|
        true unless product.category == options[:category]
      end
      if options[:quality].present?
        returned_products.reject! do |product|
          true unless product.quality == options[:quality]
        end
      end
    end
    returned_products
  end

  def store_taxon
    Spree::Taxon.where(
      name: slug,
      taxonomy: Spree::Taxonomy.where(name: 'Stores').first_or_create
    ).first_or_create
  end

  def store_categories
    generic_products = Spree::Classification.where(product: products, taxon: generic_taxon).uniq.pluck(:product_id)
    Spree::Taxon.where(
      id: Spree::Classification.where(taxon: categories_taxons, product_id: generic_products).uniq.pluck(:taxon_id)
    )
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
