class PlaqueColourController < PlaqueDetailsController

  layout 'plaque_edit', only: :edit

  def edit
    @colours = Colour.order(:name)
    render "plaques/colour/edit"
  end

end
