class PlaquesLatestController < ApplicationController

  def show
    @plaques = Plaque.order('created_at desc').limit(25)
    respond_to do |format|
      format.html
      format.json { render json: @plaques }
      format.geojson { render geojson: @plaques }
      format.rss {
        response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"
      }
    end
  end

end
