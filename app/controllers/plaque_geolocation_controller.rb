class PlaqueGeolocationController < PlaqueDetailsController

  def edit
    @areas = Area.preload(:country)
    render 'plaques/geolocation/edit'
  end

end
