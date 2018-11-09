class CountriesController < ApplicationController

  before_action :authenticate_admin!, only: :destroy
  before_action :authenticate_user!, except: [:index, :show]
  before_action :find, only: [:edit, :update]
  before_action :streetview_to_params, only: :update

  def index
    @countries = Country.all.to_a
    @countries.delete_if { |x| x.plaques_count == 0 }
    @countries.sort! { |a,b| b.plaques_count <=> a.plaques_count }
    set_meta_tags open_graph: {
      type: :website,
      url: url_for(only_path: false),
      image: view_context.root_url[0...-1] + view_context.image_path('openplaques-icon.png'),
      title: 'countries that have plaques',
      description: 'countries that have plaques',
    }
    set_meta_tags twitter: {
      card: 'summary_large_image',
      site: '@openplaques',
      title: 'countries that have plaques',
      image: {
        _: view_context.root_url[0...-1] + view_context.image_path('openplaques-icon.png'),
        width: 100,
        height: 100,
      }
    }
    respond_to do |format|
      format.html
      format.json { render json: @countries }
      format.geojson { render geojson: @countries }
    end
  end

  def new
    @country = Country.new
  end

  def create
    @country = Country.new(country_params)
    if @country.save
      redirect_to country_path(@country)
    else
      render :new
    end
  end

  def show
    begin
      @country = Country.find_by_alpha2!(params[:id])
      @areas = @country.areas #.select(:id,:name,:country_id,:slug,:plaques_count)
    rescue
      @country = Country.find(params[:id])
      redirect_to(country_url(@country), status: :moved_permanently) and return
    end
    respond_to do |format|
      format.html
      format.json { render json: @country }
      format.geojson { render geojson: @country }
    end
  end

  def update
    if @country.update_attributes(country_params)
      redirect_to country_path(@country)
    else
      render :edit
    end
  end

  protected

    def find
      @country = Country.find_by_alpha2!(params[:id])
    end

    class Helper
      include Singleton
      include PlaquesHelper
    end

    def streetview_to_params
      if (params[:streetview_url])
        point = Helper.instance.geolocation_from params[:streetview_url]
        if !point.latitude.blank? && !point.longitude.blank?
          params[:country][:latitude] = point.latitude.to_s
          params[:country][:longitude] = point.longitude.to_s
        end
      end
    end

  private

    def country_params
      params.require(:country).permit(
        :alpha2,
        :latitude,
        :longitude,
        :name,
        :preferred_zoom_level,
        :streetview_url,
        :wikidata_id,
      )
    end
end
