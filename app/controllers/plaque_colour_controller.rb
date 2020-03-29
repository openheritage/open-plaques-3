# edit plaque colour
class PlaqueColourController < PlaqueDetailsController
  layout 'plaque_edit', only: :edit

  def edit
    @colours = Colour.alphabetically
    render 'plaques/colour/edit'
  end
end
