Spree::UsersController.class_eval do
  def update
    if @user.update_attributes(user_params)
      if params[:user][:password].present?
        user = Spree::User.reset_password_by_token(params[:user])
        sign_in(user, event: :authentication, bypass: !Spree::Auth::Config[:signout_after_password_change])
      end
      redirect_to main_app.dashboards_url, notice: Spree.t(:account_updated)
    else
      render :edit
    end
  end
end
