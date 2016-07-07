class PlaqueErectedController < PlaqueDetailsController

  def edit
    @organisations = Organisation.order(:name)
    @series = Series.order(:name)
    render "plaques/erected/edit"
  end

end
