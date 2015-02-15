class SeriesPlaquesController < ApplicationController

  before_filter :find, :only => [:show]

  def show
    @plaques = @series
    zoom = params[:zoom].to_i
    if zoom > 0
      x = params[:x].to_i
      y = params[:y].to_i
      @plaques = @series.plaques.tile(zoom, x, y, '')
    end
    respond_to do |format|
      format.json {
        render :json => @plaques.as_json()
      }
    end
  end

  protected

    def find
      @series = Series.find(params[:series_id])
    end

end
