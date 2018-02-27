class AreasController < ApplicationController

  before_action :authenticate_admin!, only: :destroy
  before_action :authenticate_user!, except: [:autocomplete, :index, :show, :update]
  before_action :find_country, only: [:index, :new, :show, :create, :edit, :update, :destroy]
  before_action :find, only: [:show, :edit, :update, :destroy]

  def index
    @areas = @country.areas.all
    respond_to do |format|
      format.html
      format.json { render json: @areas }
      format.geojson { render geojson: @areas }
    end
  end

  def autocomplete
    limit = params[:limit] ? params[:limit] : 5
    country_id = params[:country_id]
    if params[:contains]
      @areas = Area.select(:id,:name,:country_id).name_contains(params[:contains]).includes(:country).limit(limit)
    elsif params[:starts_with]
      if country_id == nil
        @areas = Area.select(:id,:name,:country_id).name_starts_with(params[:starts_with]).includes(:country).limit(limit)
      else
        @areas = Area.select(:id,:name,:country_id).where(country_id: country_id).name_starts_with(params[:starts_with]).includes(:country).limit(limit)
      end
    else
      @areas = "{}"
    end
    render json: @areas.as_json(
      only: [:id,:name,:country_id],
      include: {
        country: {
          only: [:name]
        }
      }
    )
  end

  def new
    @area = @country.areas.new
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @area }
      format.geojson { render geojson: @area }
    end
  end

  def create
    @area = @country.areas.new(area_params)
    if @area.save
      redirect_to country_area_path(@area.country_alpha2, @area.slug)
    else
      render :new
    end
  end

  # DELETE /areas/aa
  def destroy
    @area.destroy
    redirect_to country_path(@country)
  end

  def edit
    @countries = Country.all.select(:id, :name)
  end

  def update
    if (params[:streetview_url])
      point = help.geolocation_from params[:streetview_url]
      if !point.latitude.blank? && !point.longitude.blank?
        params[:area][:latitude] = point.latitude.to_s
        params[:area][:longitude] = point.longitude.to_s
      end
    end
    if @area.update!(area_params)
      flash[:notice] = 'Area was successfully updated.'
    end
    redirect_back(fallback_location: root_path)
  end

  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include PlaquesHelper
  end

  protected

    def find_country
      @country = Country.find_by_alpha2!(params[:country_id])
    end

    def find
      @area = @country.areas.find_by_slug!(params[:id])
      if !@area.geolocated?
        @area.find_centre
        @area.save if (@area.plaques.geolocated.size > 3)
      end
    end

  private

    def area_params
      params.require(:area).permit(
        :name,
        :slug,
        :country_id,
        :latitude,
        :longitude,
        :streetview_url,
        :country_id)
	   end

end
