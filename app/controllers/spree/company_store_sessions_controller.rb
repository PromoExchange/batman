class Spree::CompanyStoreSessionsController < Spree::StoreController
  helper 'spree/base'
  layout 'company_store_layout'

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Order
  include Spree::Core::ControllerHelpers::Store

  def create
    user = Spree::User.find_by_email(params[:spree_user][:email])

    if user.valid_password?(params[:spree_user][:password])
      session[:spree_user] = user.email
      respond_to do |format|
        format.html do
          flash[:success] = Spree.t(:logged_in_succesfully)
          redirect_back_or_default(after_sign_in_path_for(spree_current_user))
        end
        format.js do
          render json: {
            user: spree_current_user,
            ship_address: spree_current_user.ship_address,
            bill_address: spree_current_user.bill_address
          }.to_json
        end
      end
    else
      session.delete(:spree_user)
      respond_to do |format|
        format.html do
          flash.now[:error] = t('devise.failure.invalid')
          render :new
        end
        format.js do
          render json: { error: t('devise.failure.invalid') }, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def accurate_title
    Spree.t(:login)
  end

  def redirect_back_or_default(default)
    redirect_to(session['spree_user_return_to'] || default)
    session['spree_user_return_to'] = nil
  end

  def after_sign_in_path_for(_user)
    "/company_store/#{@current_company_store.slug}"
  end
end
