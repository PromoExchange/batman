class Spree::DashboardsController < Spree::StoreController
  before_action :require_login
  def index
    @favorites = Spree::Favorite.where(buyer: current_spree_user)
      .includes(:product)

    @logo = Spree::Logo.new
    @user = spree_current_user
    @pxaccount = Spree::Pxaccount.new(@user)

    return unless spree_current_user.has_spree_role?(:seller) || spree_current_user.has_spree_role?(:admin)

    create_taxrates
    @tax_rates = Spree::TaxRate.where(user: current_spree_user).includes(:zone)
  end

  private

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
end
