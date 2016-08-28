class SeriesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :find, :only => [:show, :edit, :update]

  def index
    @series = Series.all
    respond_to do |format|
      format.html
      format.json { render :json => @series }
      format.geojson { render :geojson => @series }
    end
  end

  def show
    @plaques = @series.plaques
      .order('series_ref asc')
      .paginate(:page => params[:page], :per_page => 20) # Postgres -> NULLS LAST
      .preload(:personal_connections, :language, :photos, area: :country )
    respond_to do |format|
      format.html
      format.json { render :json => @series }
      format.geojson { render :geojson => @series }
    end
  end

  def new
    @series = Series.new
  end

  def create
    @series = Series.new(series_params)
    if @series.save
      redirect_to series_path(@series)
    end
  end

  def update
    if (params[:streetview_url] && params[:streetview_url]!='')
      point = help.geolocation_from params[:streetview_url]
      if !point.latitude.blank? && !point.longitude.blank?
        params[:series][:latitude] = point.latitude
        params[:series][:longitude] = point.longitude
      end
    end
    if @series.update_attributes(series_params)
      flash[:notice] = 'Updates to series saved.'
      redirect_to series_path(@series)
    else
      render :edit
    end
  end

  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include PlaquesHelper
  end
  
  protected

    def find
      @series = Series.find(params[:id])
    end

  private

    def series_params
      params.require(:series).permit(
        :name,
        :description,
        :latitude,
        :longitude,
        :streetview_url)
    end  
end
