class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from(ActiveRecord::RecordInvalid) { |e| render_error('Unable to modify data', e.record.errors) }
  rescue_from(ActiveRecord::RecordNotFound) { render_error('Record not found', {}, 404) }
  rescue_from(Pundit::NotAuthorizedError) { render_error('Insufficient permissions', {}, 403) }
  rescue_from(ActionController::ParameterMissing) { |e| render_error(e.message, {}, 400) }
  rescue_from(ActionController::BadRequest) { |e| render_error(e.message, {}, 400) }

  def render_error(message, data = {}, status = 400)
    @message = message
    @data = data
    redirect_to :back, alert: @message
  end
end
