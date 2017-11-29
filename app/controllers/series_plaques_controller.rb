class SeriesPlaquesController < ApplicationController

  before_action :find, only: [:show]

  def show
    zoom = params[:zoom].to_i
    if zoom > 0
      x = params[:x].to_i
      y = params[:y].to_i
      @plaques = @series.plaques.tile(zoom, x, y, '')
    else
      @plaques = @series.plaques
    end
    respond_to do |format|
      format.json { render json: @plaques }
      format.geojson { render geojson: @plaques.geolocated, parent: @series }
      format.csv {
        send_data(
          "\uFEFF#{PlaqueCsv.new(@plaques).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@series.slug}-#{Date.today.to_s}.csv",
          disposition: 'attachment'
        )
      }
    end
  end

  protected

    def find
      @series = Series.find(params[:series_id])
    end

end
