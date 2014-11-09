module LanguagesHelper

  def language_path(language, options = {})
    url_for(options.merge(:controller => :languages, :action => :show, :id => language.alpha2))
  end

end
