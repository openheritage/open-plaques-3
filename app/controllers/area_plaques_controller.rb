class AreaPlaquesController < ApplicationController

  before_filter :find, :only => [:show]
  respond_to :html, :json, :csv

  def show
    @display = 'all'
    if (params[:id] && params[:id]=='unphotographed')
      request.format == 'html' ?
        @plaques = @area.plaques.unphotographed.paginate(:page => params[:page], :per_page => 50)
        : @plaques = @area.plaques.unphotographed
      @display = 'unphotographed'
    elsif (params[:id] && params[:id]=='current')
      request.format == 'html' ?
        @plaques = @area.plaques.current.paginate(:page => params[:page], :per_page => 50)
        : @plaques = @area.plaques.current
    elsif (params[:id] && params[:id]=='ungeolocated')
      request.format == 'html' ?
        @plaques = @area.plaques.ungeolocated.paginate(:page => params[:page], :per_page => 50)
        : @plaques = @area.plaques.ungeolocated
      @display = 'ungeolocated'
    else
      request.format == 'html' ?
        @plaques = @area.plaques.paginate(:page => params[:page], :per_page => 50)
        : @plaques = @area.plaques
    end
    @area.find_centre if !@area.geolocated?
    respond_with @plaques do |format|
      format.html
      format.json { render :json => @plaques }
      format.geojson { render :geojson => @plaques.geolocated, :parent => @area }
      format.csv {
        send_data(
          PlaqueCsv.new(@plaques).build,
          :type => 'text/csv',
          :filename => 'open-plaques-' + @area.slug + '-' + Date.today.to_s + '.csv',
          :disposition => 'attachment'
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
