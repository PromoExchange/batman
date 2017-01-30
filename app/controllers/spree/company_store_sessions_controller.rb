class Spree::CompanyStoreSessionsController < Spree::StoreController
  helper 'spree/base'
  layout 'company_store_layout'

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Order
  include Spree::Core::ControllerHelpers::Store

  def create
    user = @current_company_store.buyer

    if user.valid_password?(params[:spree_user][:password])
      session[:spree_user] = user.email
      redirect_back_or_default(after_sign_in_path_for(spree_current_user))
    else
      session.delete(:spree_user)
      flash.now[:error] = t('devise.failure.invalid')
      render :new
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
