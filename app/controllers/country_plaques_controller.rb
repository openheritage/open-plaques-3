class CountryPlaquesController < ApplicationController

  before_action :find, only: [:show]

  def show
    @display = 'all'
    if (params[:id] && params[:id]=='unphotographed')
      request.format == 'html' ? @plaques = @country.plaques.unphotographed.paginate(page: params[:page], per_page: 50) : @plaques = @country.plaques.unphotographed
      @display = 'unphotographed'
    elsif (params[:id] && params[:id]=='current')
      request.format == 'html' ? @plaques = @country.plaques.current.paginate(page: params[:page], per_page: 50) : @plaques = @country.plaques.current
    elsif (params[:id] && params[:id]=='ungeolocated')
      request.format == 'html' ? @plaques = @country.plaques.ungeolocated.paginate(page: params[:page], per_page: 50) : @plaques = @country.plaques.ungeolocated
      @display = 'ungeolocated'
    else
      request.format == 'html' ? @plaques = @country.plaques.paginate(page: params[:page], per_page: 50) : @plaques = @country.plaques
    end
    respond_to do |format|
      format.html
      format.json { render json: @plaques }
      format.geojson { render geojson: @plaques, parent: @country }
      format.csv {
        send_data(
          "\uFEFF#{PlaqueCsv.new(@plaques).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@country.name}-#{Date.today.to_s}.csv",
          disposition: 'attachment'
        )
      }
    end
  end

  protected

    def find
      @country = Country.find_by_alpha2!(params[:country_id])
    end

end
