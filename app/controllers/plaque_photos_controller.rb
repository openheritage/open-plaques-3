class PlaquePhotosController < ApplicationController

  before_filter :find
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

    def find
      @plaque = Plaque.find(params[:plaque_id])
    end

end
