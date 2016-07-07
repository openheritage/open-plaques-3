class PlaqueInscriptionController < PlaqueDetailsController

  def edit
    @languages = Language.order(:name)
    render 'plaques/inscription/edit'
  end

end
