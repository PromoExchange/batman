class Spree::Api::MessagesController < Spree::Api::BaseController
  before_action :fetch_message, except: [:index, :create]

  def index
    @messages = Spree::Message.all
      .page(params[:page])
      .per(params[:per_page] || Spree::Config[:orders_per_page])

    render 'spree/api/messages/index'
  end

  def show
    render 'spree/api/messages/show'
  end

  def create
    if @message.present?
      render nothing: true, status: :conflict
    else
      @message = Spree::Message.new
      save_message
    end
  end

  def update
    save_message
  end

  def destroy
    @message.destroy
    render nothing: true, status: :ok
  end

  private

  def message_params
    params.require(:message).permit(:owner_id,
      :from_id,
      :to_id,
      :status,
      :subject,
      :body,
      :page,
      :per_page)
  end

  def fetch_message
    @message = Spree::Message.find(params[:id])
  end

  def save_message
    @json = JSON.parse(request.body.read)
    @message.assign_attributes(@json)
    if @message.save
      render 'spree/api/messages/show'
    else
      render nothing: true, status: :bad_request
    end
  end
end
