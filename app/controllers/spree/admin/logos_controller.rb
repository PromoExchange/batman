class Spree::Admin::LogosController < Spree::Admin::ResourceController
  before_action :load_user
  before_action :load_logo, only: [:destroy, :show]

  def create
    binding.pry
  end

  def destroy
    @logo.destroy!
  end

  def new
    @logo = Spree::Logo.new(user: @user)
  end

  private

  def load_logo
    @logo = Spree::Logo.find params[:id]
  end

  def load_user
    @user = Spree::User.find params[:user_id]
  end

  def logo_params
    params.require(:logo).permit([:name, :dc_acct_num] | [
      ship_address_attributes: permitted_address_attributes,
      bill_address_attributes: permitted_address_attributes
    ])
  end
end
