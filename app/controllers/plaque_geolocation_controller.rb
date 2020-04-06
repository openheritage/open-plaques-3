# geolocate a plaque
class PlaqueGeolocationController < PlaqueDetailsController
  def edit
    @areas = Area.preload(:country).alphabetically
    render 'plaques/geolocation/edit'
  end
end
