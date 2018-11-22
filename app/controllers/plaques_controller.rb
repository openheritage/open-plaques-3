require 'julia'

class PlaquesController < ApplicationController

  before_action :authenticate_user!, only: [:edit]
  before_action :authenticate_admin!, only: :destroy
  before_action :find, only: [:show, :flickr_search, :flickr_search_all, :update, :destroy, :edit]
#	 before_action :set_cache_header, only: :index
#  after_filter :set_access_control_headers, only: :index
  layout 'plaque_edit', only: :edit

  def index
    conditions = {}
    if params[:box]
      # box = top_left, bottom_right
      # e.g. http://0.0.0.0:3000/plaques?box=[52.00,-1],[50.00,0.01]
      coords = params[:box][1,params[:box].length-2].split("],[")
      top_left = coords[0].split(",")
      bottom_right = coords[1].split(",")
      conditions[:latitude] = bottom_right[0].to_s..top_left[0].to_s
      conditions[:longitude] = top_left[1].to_s..bottom_right[1].to_s
    end
    if params[:since]
      since = DateTime.parse(params[:since])
      now = DateTime.now
      if since && since < now
        since = since + 1.second
        conditions[:updated_at] = since..now
      end
    end
    if params[:limit] # && params[:limit].to_i <= 2000
      @limit = params[:limit]
    elsif params[:limit]
      @limit = 200000000
    else
      @limit = 20
    end
    select = "all"
    select = "unphotographed" if params[:filter] == "unphotographed"
    zoom = params[:zoom].to_i
    if zoom > 0
      # or map tile http://0.0.0.0:3000/plaques/12/2046/1374.json

      @plaques = Plaque.tile(zoom, params[:x].to_i, params[:y].to_i, select)
    elsif params[:data] && params[:data] == "simple"
      @plaques = Plaque.where(conditions).order("created_at DESC").limit(@limit)
    elsif params[:data] && params[:data] == "basic"
      @plaques = Plaque.all(select: [:id, :latitude, :longitude, :inscription])
    else
#      @limit = 1000000000000
      @plaques = Plaque.where(conditions).order("created_at DESC").limit(@limit).preload(:language, :organisations, :colour, [area: :country])
    end

    respond_to do |format|
      format.html
      format.json {
        if params[:data] && params[:data] == "simple"
          render json: @plaques.as_json(only: [:id, :latitude, :longitude, :inscription],
            methods: [:title, :colour_name, :machine_tag, :thumbnail_url])
        elsif params[:data] && params[:data] == "basic"
          render json: @plaques.as_json(only: [:id, :latitude, :longitude, :inscription])
        else
          render json: @plaques.as_json(only: [:id, :latitude, :longitude, :inscription])
        end
      }
      format.geojson { render geojson: @plaques }
      format.rss { render json: {error: "format unsupported"}.to_json, status: 406 }
      format.csv {
        send_data(
          "\uFEFF#{PlaqueCsv.new(@plaques).build}",
          type: 'text/csv',
          filename: "open-plaques-all-#{Date.today.to_s}.csv",
          disposition: 'attachment'
        )
      }
    end
  end

  def show
    @plaques = [@plaque]
    begin
      set_meta_tags description: "#{@plaque.title}"
      set_meta_tags open_graph: {
        type: :website,
        url: url_for(only_path: false),
        image: @plaque.main_photo ? @plaque.main_photo.file_url : view_context.root_url[0...-1] + view_context.image_path('openplaques.png'),
        title: @plaque.title,
        description: @plaque.inscription,
      }
      set_meta_tags twitter: {
        card: "summary_large_image",
        site: "@openplaques",
        title: @plaque.title,
        image: {
          _: @plaque.main_photo ? @plaque.main_photo.file_url : view_context.root_url[0...-1] + view_context.image_path('openplaques.png'),
          width: 100,
          height: 100,
        }
      }
    rescue
    end

    respond_to do |format|
      format.html
      format.xml { render "plaques/index" }
      format.kml { render json: {error: "format unsupported"}.to_json, status: 406 }
      format.json { render json: @plaque }
      format.geojson { render geojson: @plaque }
      format.csv {
        @plaques = []
        @plaques << @plaque
        send_data(
          "\uFEFF#{PlaqueCsv.new(@plaques).build}",
          type: 'text/csv',
          filename: "open-plaque-#{@plaque.id.to_s}.csv",
          disposition: 'attachment'
        )
      }
    end
  end

  def new
    @plaque = Plaque.new(language_id: 1)
    @plaque.photos.build
    @countries = Country.order(:name)
    @languages = Language.order("plaques_count DESC nulls last")
    @common_colours = Colour.common.order("plaques_count DESC")
    @other_colours = Colour.uncommon.order(:name)
  end

  def flickr_search
    help.find_photo_by_machinetag(@plaque, nil)
    help.find_flickr_photos_non_api(@plaque)
    redirect_to @plaque
  end

  def flickr_search_all
    help.find_photo_by_machinetag(nil, nil)
    redirect_to @plaque
  end

  def create
    @plaque = Plaque.new(plaque_params)

    # early intervention to reject spam messages
    redirect_to plaques_url and return if params[:plaque][:inscription].include? "http"
    redirect_to plaques_url and return if params[:plaque][:inscription].include? "href"
    redirect_to plaques_url and return if params[:plaque][:inscription].blank?
    redirect_to plaques_url and return if params[:plaque][:inscription].start_with?("1") && params[:plaque][:inscription].to_s.size < 10
    redirect_to plaques_url and return if params[:plaque][:inscription].to_s.size < 8
    redirect_to plaques_url and return if params[:area] == "New York" && params[:plaque][:country] != "13"

    country = Country.find(params[:plaque][:country].blank? ? 1 : params[:plaque][:country])
    if params[:area_id] && !params[:area_id].blank?
      area = Area.find(params[:area_id])
      raise "ERROR" if area.country_id != country.id and return
    elsif params[:area] && !params[:area].blank?
      area = country.areas.find_by_name(params[:area])
      unless area
        area = country.areas.find_by_slug(params[:area].rstrip.lstrip.downcase.tr(" ", "_"))
      end
      unless area
        area = country.areas.create!(name: params[:area])
      end
    end
    @plaque.area = area

    unless params[:organisation_name].empty? || params[:organisation_name].downcase == "none" || params[:organisation_name].downcase == "unknown"
      organisation = Organisation.where(name: params[:organisation_name]).first_or_create
      @plaque.organisations << organisation if organisation.valid?
    end

    if @plaque.save
      flash[:notice] = "Thanks for adding this plaque."
      redirect_to plaque_path(@plaque)
    else
      params[:checked] = "true"
      @plaque.photos.build if @plaque.photos.size == 0
      @countries = Country.order(:name)
      @languages = Language.order("plaques_count DESC nulls last")
      @common_colours = Colour.common.order("plaques_count DESC")
      @other_colours = Colour.uncommon.order(:name)
      render :new
    end
  end

  def update
    if (params[:streetview_url])
      point = help.geolocation_from params[:streetview_url]
      if !point.latitude.blank? && !point.longitude.blank?
        params[:plaque][:latitude] = point.latitude
        params[:plaque][:longitude] = point.longitude
      end
    end
    if params[:plaque] && params[:plaque][:colour_id]
      @colour = Colour.find(params[:plaque][:colour_id])
      if @plaque.colour_id != @colour.id
        @plaque.colour = @colour
        @plaque.save
      end
    end
    respond_to do |format|
      if @plaque.update_attributes(plaque_params)
        flash[:notice] = 'Plaque was successfully updated.'
        format.html { redirect_to(@plaque) }
        format.xml  { head :ok }
      else
        format.html { render "edit" }
        format.xml  { render xml: @plaque.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @plaque.destroy
    redirect_to(plaques_url)
  end

  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include PlaquesHelper
  end

  private

    def find
      @plaque = Plaque.find(params[:id])
    end

  	def plaque_params
        params.require(:plaque).permit(
          # for new plaque form
          :inscription,
          :inscription_is_stub,
          :language_id,
          :address,
          :area,
          :country,
          :organisation_name,
          :organisation_id,
          'erected_at(1i)', 'erected_at(3i)', 'erected_at(2i)',
          :colour_id,
          :other_colour_id,
          # for plaque update
          :notes,
          :inscription_in_english,
          :description,
          :area_id,
          :latitude,
          :longitude,
          :is_accurate_geolocation,
          :erected_at_string,
          :is_current,
          :series_id,
          :series_ref,
        )
  	end
end
