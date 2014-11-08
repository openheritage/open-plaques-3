module VerbsHelper

  def verb_path(verb, options = {})
    url_for(options.merge(:controller => :verbs, :action => :show, :id => verb))
  end

end
