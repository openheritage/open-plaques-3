class PlaqueDescriptionController < ApplicationController

  before_filter :authenticate_user!

  def edit
  	@plaque = Plaque.find(params[:plaque_id])
    render "plaques/description/edit"
  end

end