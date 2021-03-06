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

  def display_name
    self[:display_name].nil? ? (slug || '').titleize : self[:display_name]
  end

  def products(options = {})
    Rails.cache.fetch("#{cache_key}/products/#{options}", expires_in: 6.hours) do
      returned_products = store_taxon.products.to_a

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
  end

  def generic_products
    generic_taxon.products & store_taxon.products
  end

  def store_taxon
    Spree::Taxon.where(
      name: slug,
      taxonomy: Spree::Taxonomy.where(name: 'Stores').first_or_create
    ).first_or_create
  end

  def store_categories
    Rails.cache.fetch("#{cache_key}/store_categories", expires_in: 6.hours) do
      categories_taxons.where(
        id: Spree::Classification.where(
          product_id: generic_products
        ).pluck(:taxon_id)
      ).sort_by(&:name)
    end
  end

  def seller
    Rails.cache.fetch("#{cache_key}/seller", expires_in: 6.hours) do
      Spree::User.find_by(email: ENV['SELLER_EMAIL'])
    end
  end

  def cache_keys
    cache_data = Rails.cache.instance_variable_get('@data')
    cache_data.keys.select { |k, _v| k.start_with?(cache_key) } unless cache_data.nil?
  end

  def clear_cache
    products.each(&:clear_cache)
    return if cache_keys.nil?
    cache_keys.each do |k|
      Rails.cache.delete(k)
    end
  end

  def cache_key
    "#{model_name.cache_key}/#{id || 'new'}"
  end
end
