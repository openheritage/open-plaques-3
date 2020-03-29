# edit plaque inscriptions
class PlaqueInscriptionController < PlaqueDetailsController
  layout 'plaque_edit', only: :edit

  def edit
    @languages = Language.alphabetically
    render 'plaques/inscription/edit'
  end
end
