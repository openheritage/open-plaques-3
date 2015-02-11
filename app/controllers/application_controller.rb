class UnAuthorised < StandardError; end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_filter :global_request_logging

  def authenticate_admin!
    raise UnAuthorised, "NotAuthorised" unless current_user.try(:is_admin?)
  end

  def global_request_logging 
    puts "USERAGENT: #{request.path} #{request.headers['HTTP_USER_AGENT']}"
    begin 
      yield 
    ensure 
#      puts "response_status: #{response.status}"
    end 
  end 

end
