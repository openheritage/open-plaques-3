class PlaqueColourController < ApplicationController

  def edit
    @plaque = Plaque.find(params[:plaque_id])
    @colours = Colour.find(:all, :order => :name)
    render "plaques/colour/edit"
  end

end