class SeriesPlaquesController < ApplicationController

  before_filter :find, :only => [:show]

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
      format.json {
        render :json => @plaques.as_json(Plaque.as_minimal_geojson)
      }
    end
  end

  protected

    def find
      @series = Series.find(params[:series_id])
    end

end
