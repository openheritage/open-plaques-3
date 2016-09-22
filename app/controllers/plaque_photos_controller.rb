class PlaquePhotosController < PlaqueDetailsController

  def show
  	respond_to do |format|
      format.html { render 'plaques/photos/show' }
      format.json { render json: @plaque.photos }
      format.geojson { render geojson: @plaque.photos }
    end
  end

end
