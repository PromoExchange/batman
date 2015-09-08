class Spree::PxaccountsController < Spree::StoreController
  def new
    @pxaccount = Spree::Pxaccount.new(current_spree_user)
  end

  def index
    redirect_to dashboards_path
  end

  def create
    user = Spree::User.find(spree_current_user.id)

    if user.update_attributes(pxaccount_params)
      if params[:pxaccount][:password].present?
        user = Spree::User.reset_password_by_token(pxaccount_params)
        sign_in(user, event: :authentication, bypass: !Spree::Auth::Config[:signout_after_password_change])
      end
    end
    redirect_to main_app.dashboards_url, notice: Spree.t(:account_updated)

  rescue
    @pxaccount = Spree::Pxaccount.new
    params[:account].each do |k, v|
      @pxaccount.instance_variable_set("@#{k}", v)
    end
    @pxaccount.errors = user.errors.full_messages
    render :new
  end

  def update_address(address, fields)
    country_id = Spree::Country.where(name: fields[:country]).first.id

    if country_id.nil?
      country_id = Spree::Country.where(name: 'United States').first.id
    end

    fields[:country_id] = country_id
    fields.delete(:country)

    %w(
      company
      firstname
      lastname
      address1
      address2
      city
      state_id
      phone
      country_id
      zipcode
    ).each do |k|
      address.update_attribute(k, fields[k.to_sym])
    end
  end

  def pxaccount_params
    params.require(:pxaccount).permit(
      :id,
      :email_address,
      :password,
      :password_confirmation,
      :bill_address,
      :ship_address
    )
  end
end
