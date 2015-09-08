# If we do not prefix this with PX we would run into a clash
# with the Spree API endpoint.
# This will be addressed as part of the larger API/namespace refactor
class Spree::Api::PxaddressesController < Spree::Api::BaseController
  before_action :fetch_address, except: [:index, :create]

  def type
    user = Spree::User.find(params[:user_id])

    if params[:type] == 'bill'
      user.bill_address_id = params[:id]
    else
      user.ship_address_id = params[:id]
    end

    user.save!

    render nothing: true, status: :ok
  end

  def index
    params[:user_id] = {} if params[:user_id].blank?

    @addresses = Spree::Address.search(
      user_id_eq: params[:user_id]
    ).result

    render 'spree/api/addresses/index'
  end

  def show
    @address = Spree::Address.find(params[:id])
    render 'spree/api/addresses/show'
  end

  def create
    if @address.present?
      render nothing: true, status: :conflict
    else
      @address = Spree::Address.new
      save_address
    end
    render 'spree/api/addresses/show'
  end

  def update
    save_address
    render nothing: true, status: :ok
  end

  def destroy
    @address.update_attributes(deleted_at: Time.zone.now)
    render nothing: true, status: :ok
  end

  private

  def save_address
    ids = Spree::State.joins(:country)
      .merge(Spree::Country.where(iso3: 'USA'))
      .where(abbr: params[:state])
      .pluck(:country_id, :id)
      .first

    @address.assign_attributes(
      company: params[:company],
      firstname: params[:firstname],
      lastname: params[:lastname],
      address1: params[:address1],
      address2: params[:address2],
      city: params[:city],
      user_id: params[:user_id],
      zipcode: params[:zipcode],
      state_name: params[:state],
      state_id: ids[1],
      country_id: ids[0],
      phone: params[:phone]
    )
    @address.save!
  end

  def fetch_address
    @address = Spree::Address.find(params[:id])
  end

  def pxaddresses_params
    params.require(:address).permit(
      :user_id,
      :address_id,
      :type
    )
  end
end
