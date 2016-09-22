class PlaqueSeriesController < PlaqueDetailsController

  layout 'plaque_edit', only: :edit

  def edit
    @series = Series.order(:name)
    render "plaques/series/edit"
  end

end
