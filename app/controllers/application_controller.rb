# deny entry
class UnAuthorised < StandardError; end

# control application
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  around_action :bot_blocker
  before_action :set_locale, :set_global_meta_tags

  def authenticate_admin!
    raise UnAuthorised, 'NotAuthorised' unless current_user.try(:is_admin?)
  end

  def bot_blocker
    http_user_agent = request.env['HTTP_USER_AGENT']&.downcase
    is_semrush = http_user_agent&.include?('semrush')
    is_the_knowledge_ai = http_user_agent&.include?('the knowledge ai')
    is_a_bot = http_user_agent&.include?('bot') ||
               http_user_agent&.include?('spider') ||
               http_user_agent&.include?('bingpreview') ||
               http_user_agent&.include?('bubing') ||
               http_user_agent&.include?('slurp') ||
               http_user_agent&.include?('java/1.7.0_79') ||
               is_semrush ||
               is_the_knowledge_ai
    is_a_data_request = ['application/json', 'application/xml', 'application/kml'].include?(request.format)
    puts "USERAGENT: #{is_a_bot ? 'bot' : 'not-bot'} #{request.format} #{request.path} #{request.headers['HTTP_USER_AGENT']}"
    is_not_following_robots_txt = is_a_data_request ||
                                  request.path.end_with?('/new') ||
                                  request.path.end_with?('/edit') ||
                                  %r{/places}.match?(request.path) ||
                                  %r{/organisation}.match?(request.path) ||
                                  %r{/photographers}.match?(request.path) ||
                                  %r{/roles}.match?(request.path) ||
                                  %r{/verbs}.match?(request.path) ||
                                  %r{/todo}.match?(request.path) ||
                                  %r{/series}.match?(request.path) ||
                                  %r{/photos}.match?(request.path)
    if is_semrush ||
       is_the_knowledge_ai ||
       (is_a_bot && is_not_following_robots_txt)
      puts "BLOCKED: #{request.headers['HTTP_USER_AGENT']}"
      render json: { error: 'no-bots' }.to_json, status: 406 and return
    end
    yield
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def set_global_meta_tags
    set_meta_tags author: 'Open Plaques'
    set_meta_tags description: 'Commemorative plaques of the world'
    set_meta_tags open_graph: {
      type: :website,
      url: url_for(only_path: false),
      image: view_context.root_url[0...-1] + view_context.image_path('openplaques.png'),
      title: 'Open Plaques',
      description: 'Documenting the historical links between people and places, as recorded by commemorative plaques'
    }
    set_meta_tags twitter: {
      card: 'summary_large_image',
      site: '@openplaques',
      title: 'Open Plaques',
      image: {
        _: view_context.root_url[0...-1] + view_context.image_path('openplaques.png'),
        width: 100,
        height: 100
      }
    }
  rescue
  end
end
