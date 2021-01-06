# control Series
class SeriesController < ApplicationController
  before_action :authenticate_admin!, only: :destroy
  before_action :find, only: %i[show edit update geolocate]
  before_action :streetview_to_params, only: :update

  def index
    @series = Series.all.alphabetically
    respond_to do |format|
      format.html
      format.json { render json: @series }
      format.geojson { render geojson: @series }
    end
  end

  def show
    if params[:series_ref]
      @plaque = Plaque.where(series_id: @series.id, series_ref: params[:series_ref]).first
      render '/plaques/show'
    else
      @plaques = @series
                 .plaques
                 .by_series_ref
                 .paginate(page: params[:page], per_page: 20)
                 .preload(:language, :personal_connections, :photos, area: :country)
      begin
        set_meta_tags open_graph: {
          title: "Open Plaques Series #{@series.name}",
          description: @series.description
        }
        @main_photo = @series.main_photo
        set_meta_tags twitter: {
          title: "Open Plaques Series #{@series.name}",
          image: {
            _: @main_photo ? @main_photo.file_url : view_context.root_url[0...-1] + view_context.image_path('openplaques.png'),
            width: 100,
            height: 100
          }
        }
      rescue
      end
      respond_to do |format|
        format.html
        format.json { render json: @series }
        format.geojson { render geojson: @series }
      end
    end
  end

  def new
    @series = Series.new
  end

  def create
    @series = Series.new(permitted_params)
    redirect_to series_path(@series) if @series.save
  end

  def update
    if @series.update(permitted_params)
      flash[:notice] = 'Updates to series saved.'
      redirect_to series_path(@series)
    else
      redirect_back(fallback_location: root_path)
    end
  end

  def geolocate
    unless @series.geolocated?
      @mean = Helper.instance.find_mean(@series.plaques.geolocated.random(50))
      @series.latitude = @mean.latitude
      @series.longitude = @mean.longitude
      @series.save
    end
    redirect_back(fallback_location: root_path)
  end

  protected

  def find
    @series = Series.find(params[:id] || params[:series_id])
  end

  # access helpers from controller
  class Helper
    include Singleton
    include PlaquesHelper
  end

  def streetview_to_params
    return unless params[:streetview_url]

    point = Helper.instance.geolocation_from(params[:streetview_url])
    return if point.latitude.blank? || point.longitude.blank?

    params[:series][:latitude] = point.latitude.to_s
    params[:series][:longitude] = point.longitude.to_s
  end

  private

  def permitted_params
    params.require(:series).permit(
      :description,
      :latitude,
      :longitude,
      :name,
      :streetview_url
    )
  end
end
