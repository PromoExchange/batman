class Spree::Admin::LogosController < Spree::Admin::ResourceController
  before_action :load_user

  respond_to :html

  def index
    puts 'here'
  end

  def create
  end

  private

  def load_user
    @user = Spree::User.find params[:id]
  end

  def logo_params
    params.require(:logo).permit([:name, :dc_acct_num] | [
      ship_address_attributes: permitted_address_attributes,
      bill_address_attributes: permitted_address_attributes
    ])
  end
end
