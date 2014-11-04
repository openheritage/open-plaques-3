class CountryPlaquesController < ApplicationController

  before_filter :find_country, :only => [:show]
  respond_to :html, :kml, :osm, :xml, :json

  def show
    @display = 'all'
    if (params[:id] && params[:id]=='unphotographed')
      if request.format == 'json' or request.format == 'xml'
        @plaques = @country.plaques.unphotographed
      else
        @plaques = @country.plaques.unphotographed.paginate(:page => params[:page], :per_page => 50)
      end
      @display = 'unphotographed'
    elsif (params[:id] && params[:id]=='current')
      if request.format == 'json' or request.format == 'xml'
        @plaques = @country.plaques.current
      else
        @plaques = @country.plaques.current.paginate(:page => params[:page], :per_page => 50)
      end
    elsif (params[:id] && params[:id]=='ungeolocated')
      if request.format == 'json' or request.format == 'xml'
        @plaques = @country.plaques.ungeolocated
      else
        @plaques = @country.plaques.ungeolocated.paginate(:page => params[:page], :per_page => 50)
      end
      @display = 'ungeolocated'
    else
      if request.format == 'json' or request.format == 'xml'
        @plaques = @country.plaques
      else
        @plaques = @country.plaques.paginate(:page => params[:page], :per_page => 50)
      end
    end
    respond_with @plaques do |format|
      format.html
      format.kml { render "plaques/index" }
      format.osm { render "plaques/index" }
      format.xml { render "plaques/index" }
      format.json { render :json => @plaques.as_json() }
    end
  end

  protected

    def find_country
      @country = Country.find_by_alpha2!(params[:country_id])
    end

end
