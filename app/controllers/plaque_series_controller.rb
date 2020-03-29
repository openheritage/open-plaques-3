# edit a plaque series
class PlaqueSeriesController < PlaqueDetailsController
  layout 'plaque_edit', only: :edit

  def edit
    @series = Series.alphabetically
    render 'plaques/series/edit'
  end
end
