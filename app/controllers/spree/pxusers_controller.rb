class Spree::PxusersController < Spree::StoreController
  def new
    @pxuser = Spree::Pxuser.new
  end

  def index
    redirect_to dashboards_path
  end

  def create
    user = nil
    Spree::User.transaction do
      user = Spree::User.new(
        email: pxuser_params[:email_address],
        login: pxuser_params[:email_address],
        password: pxuser_params[:password],
        password_confirmation: pxuser_params[:password_confirm],
        asi_number: pxuser_params[:asi_number])

      user.spree_roles << Spree::Role.find_by_name(pxuser_params[:buyer_seller])

      ids = Spree::State.joins(:country)
        .merge(Spree::Country.where(iso3: 'USA'))
        .where(abbr: pxuser_params[:state])
        .pluck(:country_id, :id)
        .first

      address = Spree::Address.create(
        firstname: pxuser_params[:first_name],
        lastname: pxuser_params[:last_name],
        address1: pxuser_params[:address_line1],
        address2: pxuser_params[:address_line2],
        company: pxuser_params[:company],
        city: pxuser_params[:city],
        zipcode: pxuser_params[:zipcode],
        state_name: pxuser_params[:state],
        state_id: ids[1],
        country_id: ids[0],
        phone: pxuser_params[:phonenumber]
      )

      user.ship_address = address
      if user.save
        user.generate_spree_api_key!
      else
        render :new
      end
    end
    redirect_to login_url
  rescue
    @pxuser = Spree::Pxuser.new
    # TODO: Fix ugly code, map pxuser to spree::user?
    # becomes?
    @pxuser.first_name = pxuser_params[:first_name]
    @pxuser.last_name = pxuser_params[:last_name]
    @pxuser.company = pxuser_params[:company]
    @pxuser.email_address = pxuser_params[:email_address]
    @pxuser.address_line1 = pxuser_params[:address_line1]
    @pxuser.address_line2 = pxuser_params[:address_line2]
    @pxuser.city = pxuser_params[:city]
    @pxuser.state = pxuser_params[:state]
    @pxuser.zipcode = pxuser_params[:zipcode]
    @pxuser.phonenumber = pxuser_params[:phonenumber]
    @pxuser.asi_number = pxuser_params[:asi_number]
    @pxuser.buyer_seller = pxuser_params[:buyer_seller]
    @pxuser.errors = user.errors.full_messages
    render :new
  end

  def pxuser_params
    params.require(:pxuser).permit(
      :first_name,
      :last_name,
      :company,
      :email_address,
      :password,
      :password_confirm,
      :address_line1,
      :address_line2,
      :city,
      :state,
      :zipcode,
      :phonenumber,
      :asi_number,
      :buyer_seller
    )
  end
end
