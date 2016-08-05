class PlaqueSeriesController < PlaqueDetailsController

  def edit
    @series = Series.order(:name)
    render "plaques/series/edit"
  end

end
