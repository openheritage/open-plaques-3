module AreasHelper

  def area_path(area, options = {})
    country_area_path(area.country, area, options)
  end

  def area_plaques_path(area, options = {})
    country_area_plaques_path(area.country, area, options)
  end

  def area_url(area, options = {})
    country_area_url(area.country, area, options)
  end

  def area_plaques_url(area, options = {})
    country_area_plaques_url(area.country, area, options)
  end

  def edit_area_path(area, options = {})
    url_for(options.merge(:controller => :areas, :action => :edit, :id => area.slug, :country_id => area.country.alpha2))
  end

  def area_unphotographed_path(area, options = {})
    url_for(options.merge(:controller => :area_plaques, :action => :show, :country_id => area.country.alpha2, :area_id => area.slug, :id => :unphotographed))
  end

  def area_ungeolocated_path(area, options = {})
    url_for(options.merge(:controller => :area_plaques, :action => :show, :country_id => area.country.alpha2, :area_id => area.slug, :id => :ungeolocated))
  end

  def list_of_area_links(areas)
    links = []
    areas.each do |area|
      links << link_to(area.name, area_path(area))
    end
    links.to_sentence.html_safe
  end


end
