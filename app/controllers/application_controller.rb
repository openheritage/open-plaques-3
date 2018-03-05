class UnAuthorised < StandardError; end

class Array
  def included_in? array
    array.to_set.superset?(self.to_set)
  end
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  around_action :bot_blocker
  before_action :set_locale, :set_global_meta_tags

  def authenticate_admin!
    raise UnAuthorised, "NotAuthorised" unless current_user.try(:is_admin?)
  end

  def bot_blocker
    is_a_bot = request.env["HTTP_USER_AGENT"]&.downcase&.include?('bot') ||
      request.env["HTTP_USER_AGENT"]&.downcase&.include?('spider') ||
      request.env["HTTP_USER_AGENT"]&.downcase&.include?('bingpreview') ||
      request.env["HTTP_USER_AGENT"]&.downcase&.include?('bubing') ||
      request.env["HTTP_USER_AGENT"]&.downcase&.include?('slurp')
    is_semrush = request.env["HTTP_USER_AGENT"]&.downcase&.include?('semrush')
    is_a_data_request = ['application/json', 'application/xml', 'application/kml'].include?(request.format)
    puts "USERAGENT: #{is_a_bot ? 'bot' : 'not-bot'} #{request.format} #{request.path} #{request.headers['HTTP_USER_AGENT']}"
    is_not_following_robots_txt = is_a_data_request ||
      request.path.end_with?("/new") ||
      request.path.end_with?("/edit") ||
      /\/places/.match?(request.path) ||
      /\/organisations/.match?(request.path) ||
      /\/photographers/.match?(request.path) ||
      /\/roles/.match?(request.path) ||
      /\/verbs/.match?(request.path) ||
      /\/todo/.match?(request.path) ||
      /\/series/.match?(request.path) ||
      /\/photos/.match?(request.path)
    if is_semrush || (is_a_bot && is_not_following_robots_txt)
      puts "BLOCKED: #{is_a_bot ? 'bot' : 'not-bot'} #{request.format} #{request.path} #{request.headers['HTTP_USER_AGENT']}"
      render json: {error: "no-bots"}.to_json, status: 406 and return
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
