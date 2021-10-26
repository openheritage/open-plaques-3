# show plaques in country
class CountryPlaquesController < ApplicationController
  before_action :find, only: :show

  def show
    @display = 'all'
    if params[:id] && params[:id] == 'unphotographed'
      @plaques = if request.format == 'html'
                   @country.plaques.unphotographed.paginate(page: params[:page], per_page: 50)
                 else
                   @country.plaques.unphotographed
                 end
      @display = 'unphotographed'
    elsif params[:id] && params[:id] == 'current'
      @plaques = if request.format == 'html'
                   @country.plaques.current.paginate(page: params[:page], per_page: 50)
                 else
                   @country.plaques.current
                 end
    elsif params[:id] && params[:id] == 'ungeolocated'
      @plaques = if request.format == 'html'
                   @country.plaques.ungeolocated.paginate(page: params[:page], per_page: 50)
                 else
                   @country.plaques.ungeolocated
                 end
      @display = 'ungeolocated'
    else
      @plaques = if request.format == 'html'
                   @country.plaques.paginate(page: params[:page], per_page: 50)
                 else
                   @country.plaques
                 end
    end
    respond_to do |format|
      format.json { render json: @plaques }
      format.geojson { render geojson: @plaques, parent: @country }
      format.csv do
        send_data(
          "\uFEFF#{PlaqueCsv.new(@plaques).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@country.name}-#{Date.today}.csv",
          disposition: 'attachment'
        )
      end
    end
  end

  protected

  def find
    @country = Country.find_by!(alpha2: params[:country_id])
  end
end
