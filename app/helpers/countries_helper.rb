module CountriesHelper

  def country_unphotographed_path(country, options = {})
    url_for(options.merge(:controller => :country_plaques, :action => :show, :country_id => country.alpha2))
  end

end
