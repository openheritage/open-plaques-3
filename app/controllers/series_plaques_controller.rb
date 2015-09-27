class SeriesPlaquesController < ApplicationController

  before_filter :find, :only => [:show]

  def show
    zoom = params[:zoom].to_i
    if zoom > 0
      x = params[:x].to_i
      y = params[:y].to_i
      @plaques = @series.plaques.tile(zoom, x, y, '')
    end
    respond_to do |format|
      format.json { render :json => @series.plaques }
      format.geojson { render :geojson => @plaques.geolocated, :parent => @series }
    end
  end

  protected

    def find
      @series = Series.find(params[:series_id])
    end

end
