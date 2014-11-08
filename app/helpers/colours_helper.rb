module ColoursHelper

  def link_to_colour(colour, options = {})
    link_to(colour.name, colour_path(colour))
  end

  # Overrides the default generated named path with one that uses the colour's name
  # (eg 'blue') as its identifier rather than its numerical ID.
  def colour_path(colour, options = {})
    url_for(options.merge(:controller => :colours, :action => :show, :id => colour.slug))
  end

  def colour_url(colour, options = {})
    colour_path(colour, options.merge(:only_path => false))
  end

end
