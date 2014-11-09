module PagesHelper

  def page_path(page, options = {})
    url_for(options.merge(:controller => :pages, :action => :show, :id => page.slug))
  end

end
