# Assist Pages
module PagesHelper
  def page_path(page, options = {})
    url_for(options.merge(controller: :pages, action: :show, id: page))
  end
end
