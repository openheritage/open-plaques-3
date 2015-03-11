class UnAuthorised < StandardError; end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  around_filter :global_request_logging
  before_action :set_locale

  def authenticate_admin!
    raise UnAuthorised, "NotAuthorised" unless current_user.try(:is_admin?)
  end

  def global_request_logging
    puts "USERAGENT: #{request.path} #{request.headers['HTTP_USER_AGENT']}"
  	if request.format == :json or request.format == :xml or request.format == :kml
      if request.env["HTTP_USER_AGENT"] && (request.env["HTTP_USER_AGENT"].include?("bot") || request.env["HTTP_USER_AGENT"].include?("BingPreview") || request.env["HTTP_USER_AGENT"].include?("slurp"))
        render :json => {:error => "no-bots"}.to_json, :status => 406 and return
      end 
    end
    if request.path.end_with?("/new") || request.path.end_with?("/edit")
      if request.env["HTTP_USER_AGENT"] && (request.env["HTTP_USER_AGENT"].include?("bot") || request.env["HTTP_USER_AGENT"].include?("BingPreview") || request.env["HTTP_USER_AGENT"].include?("slurp"))
        render :json => {:error => "no-bots"}.to_json, :status => 406 and return
      end 
    end
    begin 
      yield 
    ensure 
#      puts "response_status: #{response.status}"
    end 
  end 
 
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale if params[:locale]!=nil
  end
end
