class PlaquePhotosController < ApplicationController

  before_filter :find_plaque
  respond_to :json

  def show
  	respond_to do |format|
      format.html {
      	render 'plaques/photos/show'
      }
      format.json {
        render :json => @plaque.photos.as_json
      }
    end
  end

  protected

    def find_plaque
      @plaque = Plaque.find(params[:plaque_id])
    end

end
