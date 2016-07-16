require 'csv'
require 'open-uri'

class CompanyStoreLoader
  DEFAULT_PRODUCT_ATTRS = {
    shipping_category: Spree::ShippingCategory.find_by_name!('Default'),
    tax_category: Spree::TaxCategory.find_by_name!('Default'),
    available_on: Time.zone.now + 100.years
  }.freeze

  def self.load!(params)
    raise 'Invalid params' unless params[:email].present? && params[:store_name].present? && params[:slug].present?
    new(params).load!
  end

  def initialize(params)
    @user = Spree::User.where(email: params[:email]).first
    raise "Unable to find #{params[:email]}" if @user.nil?
    @supplier = Spree::Supplier.where(name: params[:store_name]).first
    raise 'Unable to find supplier' if @supplier.nil?
    @slug = params[:slug]
  end

  def load!
    clean
    load_products
    load_upcharges
    preconfigure
  end

  def get_file(name)
    S3_CS_BUCKET.objects["#{@slug}/data/#{name}.csv"].read
  end

  def get_image(name)
    open(S3_CS_BUCKET.objects["#{@slug}/data/product_images/#{name}.jpg"].public_url)
  end

  def clean
    Spree::Product.where(supplier: supplier).each do |product|
      Spree::Auction.where(state: :custom_auction, product: product).each do |auction|
        Spree::Bid.where(auction: auction).destroy_all
        auction.destroy
      end
      product.destroy
    end
  end

  def load_products
    CSV.parse(get_file('products'), headers: true, header_converters: :symbol) do |row|
      data = row.to_hash

      product = Spree::Product.create!(
        DEFAULT_PRODUCT_ATTRS.merge(
          sku: data[:sku],
          name: data[:item_name],
          description: data[:product_description],
          price: 1.0,
          supplier_id: supplier.id,
          custom_product: true,
          color_product: []
        )
      )
      product.images << Spree::Image.create!(attachment: get_image(product.sku), viewable: product)
      product.color_product << Spree::ColorProduct.where(product: product).first_or_create
      product.imprint_methods << Spree::ImprintMethod.where(name: data[:imprint_method]).first_or_create
      load_prices(data, product) if data[:pricecode].present?
      raise "Invalid carton #{product.sku}" unless load_carton(product, data)
      product.classifications << Spree::Classification.create!(
        taxon: Spree::Taxon.where(dc_category_guid: '7F4C59A7-6226-11D4-8976-00105A7027AA').first
      ) if data[:wearable] == 'yes'
      product.save!
    end
  end

  def load_prices(data, product)
    price_code_array = Spree::Price.price_code_to_array(price_code)
    price_code_array.size.times do |i|
      quantity = data["qty#{i + 1}".to_sym]

      range = if i == (price_code_array.size - 1)
                "#{quantity}+"
              else
                "(#{quantity}..#{data["qty#{i + 2}".to_sym].to_i - 1})"
              end

      Spree::VolumePrice.where(
        variant: product.master,
        name: range,
        range: range,
        amount: data["price#{i + 1}".to_sym],
        position: i + 1,
        discount_type: 'price',
        price_code: data[:pricecode]
      ).first_or_create
    end
  end

  def load_carton(product, data)
    product.carton.weight = data[:shipping_weight]
    product.carton.quantity = data[:shipping_quantity]
    product.carton.originating_zip = data[:fob]
    return unless data[:shipping_dimensions].present?

    dimensions = data[:shipping_dimensions].gsub(/[A-Z]/, '').delete(' ').split('x')
    product.carton.length = dimensions[0]
    product.carton.width = dimensions[1]
    product.carton.height = dimensions[2]
    product.carton.save!
    product.carton.active?
  end

  def load_upcharges
    CSV.parse(get_file('upcharges'), headers: true, header_converters: :symbol) do |row|
      data = row.to_hash
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{data[:sku]}'").first
      raise "Failed to find product #{data[:sku]}" if product.nil?

      Spree::UpchargeProduct.where(
        upcharge_type: Spree::UpchargeType.where(name: data[:type]).first_or_create,
        related_id: product.id,
        actual: data[:type].titleize,
        price_code: data[:code],
        imprint_method: Spree::ImprintMethod.where(name: data[:imprint_method]).first_or_create,
        value: data[:value],
        range: data[:range]
      ).first_or_create
    end
  end

  def preconfigure
    CSV.parse(get_file('preconfigure'), headers: true, header_converters: :symbol) do |row|
      data = row.to_hash
      product = Spree::Product.joins(:master).where("spree_variants.sku='#{data[:sku]}'").first
      raise "Failed to find product #{data[:sku]}" if product.nil?

      Spree::Preconfigure.where(
        product: product,
        buyer: @user,
        imprint_method: Spree::ImprintMethod.where(name: data[:imprint_method]).first_or_create,
        main_color: Spree::ColorProduct.where(product: product, color: data[:color]).first_or_create,
        logo: @user.logos.where(custom: true).first
      ).first_or_create
    end
  end
end
