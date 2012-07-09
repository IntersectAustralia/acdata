class ApiController < ApplicationController
  before_filter :authenticate_user!
  protect_from_forgery :except => :message

  def home
  end

  def keepalive
    head :ok
  end

  def message
    unless params.include?(:subject) and !params[:subject].nil? and
           params.include?(:message) and !params[:message].nil?
      head :bad_request
      return
    end

    begin
      Notifier.notification_from_api(current_user, params[:subject], params[:message]).deliver
    rescue Exception => ex
      logger.error(ex.message)
      logger.error(ex.backtrace.join("\n"))
      render ex.message, :status => :internal_server_error
    else
      head :created
    end
  end
end
