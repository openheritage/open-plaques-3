class PlaqueErectedController < ApplicationController

  def edit
    @plaque = Plaque.find(params[:plaque_id])
    @organisations = Organisation.order(:name)
    @series = Series.order(:name)
    render "plaques/erected/edit"
  end

end