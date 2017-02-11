module PagesHelper

  def page_path(page, options = {})
    url_for(options.merge(controller: :pages, action: :show, id: page))
  end

#  def pages_path(slug, options = {})
#    url_for(options.merge(controller: :pages, action: :show, id: slug))
#  end

end
