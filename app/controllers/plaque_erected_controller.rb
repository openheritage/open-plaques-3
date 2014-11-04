class PlaqueErectedController < ApplicationController

  def edit
    @plaque = Plaque.find(params[:plaque_id])
    @organisations = Organisation.find(:all, :order => :name)
    @series = Series.find(:all, :order => :name)
    render "plaques/erected/edit"
  end

end