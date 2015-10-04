class CountryPlaquesController < ApplicationController

  before_filter :find, :only => [:show]

  def show
    @display = 'all'
    if (params[:id] && params[:id]=='unphotographed')
      if request.format == 'html'
        @plaques = @country.plaques.unphotographed.paginate(:page => params[:page], :per_page => 50)
      else
        @plaques = @country.plaques.unphotographed
      end
      @display = 'unphotographed'
    elsif (params[:id] && params[:id]=='current')
      if request.format == 'html'
        @plaques = @country.plaques.current.paginate(:page => params[:page], :per_page => 50)
      else
        @plaques = @country.plaques.current
      end
    elsif (params[:id] && params[:id]=='ungeolocated')
      if request.format == 'html'
        @plaques = @country.plaques.ungeolocated.paginate(:page => params[:page], :per_page => 50)
      else
        @plaques = @country.plaques.ungeolocated
      end
      @display = 'ungeolocated'
    else
      if request.format == 'html'
        @plaques = @country.plaques.paginate(:page => params[:page], :per_page => 50)
      else
        @plaques = @country.plaques
      end
    end
    respond_to do |format|
      format.html
      format.xml { render 'plaques/index' }
      format.json { render :json => @plaques }
      format.geojson { render :geojson => @plaques, :parent => @country }
    end
  end

  protected

    def find
      @country = Country.find_by_alpha2!(params[:country_id])
    end

end
