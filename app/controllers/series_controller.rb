class SeriesController < ApplicationController

  before_action :authenticate_admin!, only: :destroy
  before_action :find, only: [:show, :edit, :update]

  def index
    @series = Series.all
    respond_to do |format|
      format.html
      format.json { render json: @series }
      format.geojson { render geojson: @series }
    end
  end

  def show
    if (params[:series_ref])
      @plaque = Plaque.where(series_id: @series.id, series_ref: params[:series_ref]).first
      render "/plaques/show"
    else
      @plaques = @series.plaques
        .order('series_ref asc')
        .paginate(page: params[:page], per_page: 20) # Postgres -> NULLS LAST
        .preload(:personal_connections, :language, :photos, area: :country )
        begin
          set_meta_tags open_graph: {
            title: "Open Plaques Series #{@series.name}",
            description: @series.description,
          }
          @main_photo = @series.main_photo
          set_meta_tags twitter: {
            title: "Open Plaques Series #{@series.name}",
            image: {
              _: @main_photo ? @main_photo.file_url : view_context.root_url[0...-1] + view_context.image_path("openplaques.png"),
              width: 100,
              height: 100,
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
      @series = Series.find(params[:id] ? params[:id] : params[:series_id])
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
