module SeriesHelper

  def series_path(series, options = {})
    url_for(options.merge(controller: :series, action: :show, id: series.id))
  end

  def edit_series_path(series, options = {})
    url_for(options.merge(controller: :series, action: :edit, id: series.id))
  end

  def series_url(series, options = {})
    series_path(series, options.merge!(only_path: false))
  end

  def series_unphotographed_path(series, options = {})
    url_for(options.merge(controller: :series_plaques, action: :show, series_id: series.id, filter: :unphotographed))
  end

  def series_ungeolocated_path(series, options = {})
    url_for(options.merge(controller: :series_plaques, action: :show, series_id: series.id, filter: :ungeolocated))
  end

  def series_unconnected_path(series, options = {})
    url_for(options.merge(controller: :series_plaques, action: :show, series_id: series.id, filter: :unconnected))
  end
end
