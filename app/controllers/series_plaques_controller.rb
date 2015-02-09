class SeriesPlaquesController < ApplicationController

  before_filter :find, :only => [:show]
  respond_to :json

  def show
    zoom = params[:zoom].to_i
    if zoom > 0
      x = params[:x].to_i
      y = params[:y].to_i
      @plaques = @series.plaques.tile(zoom, x, y, '')
    else
      @plaques = @organisation.plaques
    end
    respond_with @plaques do |format|
      format.html { render @plaques }
      format.json {
        render :json => @plaques.as_json(
        :only => [:id, :latitude, :longitude, :inscription],
        :methods => [:title, :uri, :colour_name]
        ) 
      }
    end
  end

  protected

    def find
      @series = Series.find(params[:series_id])
    end

end
