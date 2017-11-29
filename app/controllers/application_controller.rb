class UnAuthorised < StandardError; end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  around_action :global_request_logging
  before_action :set_locale, :set_global_meta_tags

  def authenticate_admin!
    raise UnAuthorised, "NotAuthorised" unless current_user.try(:is_admin?)
  end

  def global_request_logging
    puts "USERAGENT: #{request.path} #{request.headers['HTTP_USER_AGENT']}"
  	if request.format == :json || request.format == :xml || request.format == :kml || request.path.end_with?("/new") || request.path.end_with?("/edit")
      if request.env["HTTP_USER_AGENT"] && (request.env["HTTP_USER_AGENT"].include?("bot") || request.env["HTTP_USER_AGENT"].include?("spider") || request.env["HTTP_USER_AGENT"].include?("BingPreview") || request.env["HTTP_USER_AGENT"].include?("slurp"))
        render json: {error: "no-bots"}.to_json, status: 406 and return
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

  def set_global_meta_tags
    begin
      set_meta_tags open_graph: {
        type: :website,
        url: url_for(only_path: false),
        image: view_context.root_url[0...-1] + view_context.image_path("openplaques.png"),
        title: "Open Plaques",
        description: "Documenting the historical links between people and places, as recorded by commemorative plaques",
      }
      set_meta_tags twitter: {
        card: "summary_large_image",
        site: "@openplaques",
        title: "Open Plaques",
        image: {
          _: view_context.root_url[0...-1] + view_context.image_path("openplaques.png"),
          width: 100,
          height: 100,
        }
      }
    rescue
    end
  end
end
