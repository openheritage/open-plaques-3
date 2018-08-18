module CountriesHelper

  def country_unphotographed_path(country, options = {})
    url_for(options.merge(controller: :country_plaques, action: :show, country_id: country.alpha2))
  end

  def country_unphotographed_path(country, options = {})
    url_for(options.merge(controller: :country_plaques, action: :show, country_id: country.to_param, filter: :unphotographed))
  end

  def country_ungeolocated_path(country, options = {})
    url_for(options.merge(controller: :country_plaques, action: :show, country_id: country.to_param, filter: :ungeolocated))
  end

  def country_unconnected_path(country, options = {})
    url_for(options.merge(controller: :country_plaques, action: :show, country_id: country.to_param, filter: :unconnected))
  end
end
