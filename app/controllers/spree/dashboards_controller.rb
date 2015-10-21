class Spree::DashboardsController < Spree::StoreController
  before_action :banned?
  before_action :require_login

  def index
    @favorites = Spree::Favorite.where(buyer: current_spree_user)
      .includes(:product)

    @logo = Spree::Logo.new
    @user = spree_current_user
    @pxaccount = Spree::Pxaccount.new(@user)
    @pxaddress = Spree::Pxaddress.new
    @tab = params[:tab]

    return unless spree_current_user.has_spree_role?(:seller) || spree_current_user.has_spree_role?(:admin)

    create_taxrates
    @tax_rates = Spree::TaxRate.where(user: current_spree_user).order(:name)

    create_prebids
  end

  private

  def create_prebids
    @hacked_factory = Spree::Prebid.where(seller_id: current_spree_user).first
    return unless @hacked_factory.nil?
    products = Spree::Product.all
    products.each do |p|
      Spree::Prebid.create(
        seller: current_spree_user,
        product_id: p.id,
        eqp: false,
        eqp_discount: 0.0,
        markup: 0.0
      )
      @hacked_factory = Spree::Prebid.where(seller_id: current_spree_user).first
    end
  end

  def create_taxrates
    return if spree_current_user.tax_rates.count > 0

    usa_country = Spree::Country.where(iso3: 'USA').first
    default_tax_category = Spree::TaxCategory.where(name: 'Default').first
    usa_country.states.each do |state|
      zone = Spree::Zone.where(name: state.name).first
      tax_rate = Spree::TaxRate.new(
        amount: 0.00,
        zone_id: zone.id,
        tax_category_id: default_tax_category.id,
        included_in_price: false,
        name: "#{current_spree_user.email}:#{state.name}",
        show_rate_in_label: false,
        user_id: current_spree_user.id,
        include_in_sandh: false
      )
      tax_rate.calculator = Spree::Calculator::DefaultTax.create!
      tax_rate.save!
    end
  end

  def require_login
    redirect_to login_url unless current_spree_user
  end

  def banned?
    return if spree_current_user.nil?
    return unless spree_current_user.banned?
    sign_out spree_current_user
    flash[:error] = 'This account has been suspended....'
    root_path
  end
end
