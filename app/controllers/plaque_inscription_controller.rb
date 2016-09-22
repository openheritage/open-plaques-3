class PlaqueInscriptionController < PlaqueDetailsController

  layout 'plaque_edit', only: :edit

  def edit
    @languages = Language.order(:name)
    render 'plaques/inscription/edit'
  end

end
