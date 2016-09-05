class Spree::Admin::SuppliersController < Spree::Admin::ResourceController
  before_action :load_supplier, only: [:edit, :update, :addresses, :imprint_methods]

  respond_to :html

  def index
    respond_to do |format|
      format.html { respond_with(@collection) }
      format.csv do
        pms_colors_supplier = Spree::PmsColorsSupplier.all
        send_data pms_colors_supplier.to_csv, filename: "pms_color_by_factory-#{Time.zone.today}.csv"
      end
    end
  end

  def create
    Spree::Supplier.create(supplier_params)
    redirect_to admin_suppliers_path
  end

  def addresses
    return unless request.put?

    @supplier.build_bill_address if @supplier.build_bill_address.nil?

    bill_address_data = params[:supplier][:bill_address]

    @supplier.bill_address.firstname = bill_address_data[:firstname]
    @supplier.bill_address.company = @supplier.name
    @supplier.bill_address.lastname = bill_address_data[:lastname]
    @supplier.bill_address.address1 = bill_address_data[:address1]
    @supplier.bill_address.address2 = bill_address_data[:address2]
    @supplier.bill_address.city = bill_address_data[:city]
    @supplier.bill_address.zipcode = bill_address_data[:zipcode]
    @supplier.bill_address.country_id = bill_address_data[:country_id]
    @supplier.bill_address.state_id = bill_address_data[:state_id]
    @supplier.bill_address.phone = bill_address_data[:phone]
    @supplier.bill_address.save!

    @supplier.build_ship_address if @supplier.build_ship_address.nil?

    ship_address_data = params[:supplier][:ship_address]

    @supplier.ship_address.firstname = ship_address_data[:firstname]
    @supplier.ship_address.company = @supplier.name
    @supplier.ship_address.lastname = ship_address_data[:lastname]
    @supplier.ship_address.address1 = ship_address_data[:address1]
    @supplier.ship_address.address2 = ship_address_data[:address2]
    @supplier.ship_address.city = ship_address_data[:city]
    @supplier.ship_address.zipcode = ship_address_data[:zipcode]
    @supplier.ship_address.country_id = ship_address_data[:country_id]
    @supplier.ship_address.state_id = ship_address_data[:state_id]
    @supplier.ship_address.phone = ship_address_data[:phone]
    @supplier.ship_address.save!

    flash.now[:success] = 'Address updated' if @supplier.save!
    redirect_to admin_suppliers_path
  end

  def imprint_methods
    @imprint_methods = Spree::Product.where(supplier_id: @supplier.id)
      .joins(:imprint_methods)
      .uniq
  end

  def load_supplier
    @supplier = Spree::Supplier.find(params[:supplier_id]) unless params[:supplier_id].nil?
  end

  private

  def collection
    return @collection if @collection.present?
    params[:q] = {} if params[:q].blank?

    @collection = super
    @search = @collection.ransack(params[:q])
    @collection = @search.result
      .page(params[:page])
      .per(Spree::Config[:properties_per_page])

    @collection
  end

  def supplier_params
    params.require(:supplier).permit([:name, :company_store, :dc_acct_num] | [
      ship_address_attributes: permitted_address_attributes,
      bill_address_attributes: permitted_address_attributes
    ])
  end
end
