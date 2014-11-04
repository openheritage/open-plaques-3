class PlaqueInscriptionController < ApplicationController

  def edit
    @plaque = Plaque.find(params[:plaque_id])
    @languages = Language.all(:order => :name)
    render 'plaques/inscription/edit'
  end

end