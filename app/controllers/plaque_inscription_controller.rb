class PlaqueInscriptionController < ApplicationController

  def edit
    @plaque = Plaque.find(params[:plaque_id])
    @languages = Language.order(:name)
    render 'plaques/inscription/edit'
  end

end