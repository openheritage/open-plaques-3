class PlaqueColourController < PlaqueDetailsController

  def edit
    @colours = Colour.order(:name)
    render "plaques/colour/edit"
  end

end
