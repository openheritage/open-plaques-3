class PlaquePhotosController < PlaqueDetailsController

  def show
  	respond_to do |format|
      format.html { render 'plaques/photos/show' }
      format.json { render :json => @plaque.photos.as_json }
    end
  end

end
