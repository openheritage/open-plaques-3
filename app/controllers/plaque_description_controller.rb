class PlaqueDescriptionController < ApplicationController

  def edit
  	@plaque = Plaque.find(params[:plaque_id])
    render "plaques/description/edit"
  end

end