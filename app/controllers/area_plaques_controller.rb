class AreaPlaquesController < ApplicationController

  before_filter :find, only: [:show]
  respond_to :html, :json, :csv

  def show
    @display = 'all'
    if (params[:filter] && params[:filter]!='')
      begin
        request.format.html? ?
          @plaques = @area.plaques.send(params[:filter].to_s).paginate(page: params[:page], per_page: 50)
          : @plaques = @area.plaques.send(params[:filter].to_s)
        @display = params[:filter].to_s
      rescue # an unrecognised filter method
        request.format.html? ?
          @plaques = @area.plaques.paginate(page: params[:page], per_page: 50)
          : @plaques = @area.plaques
        @display = 'all'
      end
    else
      request.format.html? ?
        @plaques = @area.plaques.paginate(page: params[:page], per_page: 50)
        : @plaques = @area.plaques
    end
    @area.find_centre if !@area.geolocated?
    respond_with @plaques do |format|
      format.html
      format.json { render json: @plaques }
      format.geojson { render geojson: @plaques.geolocated, parent: @area }
      format.csv {
        send_data(
          PlaqueCsv.new(@plaques).build,
          type: 'text/csv',
          filename: 'open-plaques-' + @area.slug + '-' + Date.today.to_s + '.csv',
          disposition: 'attachment'
        )
      }
    end
  end

  protected

    def find
      @country = Country.find_by_alpha2!(params[:country_id])
      @area = @country.areas.find_by_slug!(params[:area_id])
    end

end
