class PlaquesLatestController < ApplicationController

  def show
    @plaques = Plaque.order('created_at desc').limit(25)
    respond_to do |format|
      format.html
      format.json { render json: @plaques }
      format.kml { render "plaques/index" }
      format.osm { render "plaques/index" }
      format.rss {
        response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"
      }
    end
  end

end

