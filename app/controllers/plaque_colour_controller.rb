class PlaqueColourController < ApplicationController

  def edit
    @plaque = Plaque.find(params[:plaque_id])
    @colours = Colour.order(:name)
    render "plaques/colour/edit"
  end

end