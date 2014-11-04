class PlaquesLatestController < ApplicationController

  def show
    @plaques = Plaque.find(:all, :limit => 25, :order => "created_at DESC")
    respond_to do |format|
      format.html
      format.kml { render "plaques/index" }
      format.osm { render "plaques/index" }
      format.rss {
        response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"
      }
    end
  end

end

