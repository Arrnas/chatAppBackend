include ActionController::HttpAuthentication::Token::ControllerMethods
include ActionController::MimeResponds
class ApplicationController < ActionController::API
  private

  def restrict_access
    unless restrict_access_by_params || restrict_access_by_header
      render json: {message: 'Invalid API Token'}, status: 401
      return
    end
  end

  def restrict_access_by_header
    return true if @current_user

    authenticate_with_http_token do |token|
      @current_user = User.find_by_access_token(token)
    end
  end

  def restrict_access_by_params
    return true if @current_user

    @current_user = User.find_by_access_token(params[:access_token])
  end
end
