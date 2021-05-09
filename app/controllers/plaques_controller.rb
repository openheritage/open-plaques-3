require 'julia'

# control Plaques
class PlaquesController < ApplicationController
  before_action :authenticate_user!, only: :edit
  before_action :authenticate_admin!, only: :destroy
  before_action :find, only: %i[show flickr_search flickr_search_all update destroy edit]
  # before_action :set_cache_header, only: :index
  # after_filter :set_access_control_headers, only: :index
  layout 'plaque_edit', only: :edit

  def index
    conditions = {}
    if params[:box]
      # box = top_left, bottom_right
      # e.g. http://0.0.0.0:3000/plaques?box=[52.00,-1],[50.00,0.01]
      coords = params[:box][1, params[:box].length - 2].split('],[')
      top_left = coords[0].split(',')
      bottom_right = coords[1].split(',')
      conditions[:latitude] = bottom_right[0].to_s..top_left[0].to_s
      conditions[:longitude] = top_left[1].to_s..bottom_right[1].to_s
    end
    if params[:since]
      since = DateTime.parse(params[:since])
      now = DateTime.now
      if since && since < now
        since += 1.second
        conditions[:updated_at] = since..now
      end
    end
    if params[:limit] # && params[:limit].to_i <= 2000
      @limit = params[:limit]
    else
      @limit = 20
    end
    select = 'all'
    select = 'unphotographed' if params[:filter] == 'unphotographed'
    zoom = params[:zoom].to_i
    minimal_attributes = %i[id latitude longitude inscription]
    @plaques = if zoom.positive?
                 Plaque.tile(zoom, params[:x].to_i, params[:y].to_i, select)
               elsif params[:data] && params[:data] == 'simple'
                 Plaque.where(conditions).order(created_at: :desc).limit(@limit)
               elsif params[:data] && params[:data] == 'basic'
                 Plaque.all(select: minimal_attributes)
               else
                 # @limit = 1000000000000
                 Plaque.where(conditions).order(created_at: :desc).limit(@limit).preload(:language, :organisations, :colour, [area: :country])
               end

    respond_to do |format|
      format.html
      format.json do
        if params[:data] && params[:data] == 'simple'
          render json: @plaques.as_json(only: minimal_attributes, methods: %i[title colour_name machine_tag thumbnail_url])
        elsif params[:data] && params[:data] == 'basic'
          render json: @plaques.as_json(only: minimal_attributes)
        else
          render json: @plaques.as_json(only: minimal_attributes)
        end
      end
      format.geojson { render geojson: @plaques }
      format.rss { render json: { error: 'format unsupported' }.to_json, status: 406 }
      format.csv do
        send_data(
          "\uFEFF#{PlaqueCsv.new(@plaques).build}",
          type: 'text/csv',
          filename: "open-plaques-all-#{Date.today}.csv",
          disposition: 'attachment'
        )
      end
    end
  end

  def show
    @plaques = [@plaque]
    begin
      set_meta_tags description: @plaque.title
      set_meta_tags open_graph: {
        type: :website,
        url: url_for(only_path: false),
        image: @plaque.main_photo ? @plaque.main_photo.file_url : view_context.root_url[0...-1] + view_context.image_path('openplaques.png'),
        title: @plaque.title,
        description: @plaque.inscription
      }
      set_meta_tags twitter: {
        card: 'summary_large_image',
        site: '@openplaques',
        title: @plaque.title,
        image: {
          _: @plaque.main_photo ? @plaque.main_photo.file_url : view_context.root_url[0...-1] + view_context.image_path('openplaques.png'),
          width: 100,
          height: 100
        }
      }
    rescue
    end

    respond_to do |format|
      format.html
      format.xml { render 'plaques/index' }
      format.kml { render json: { error: 'format unsupported' }.to_json, status: 406 }
      format.json { render json: @plaque }
      format.geojson { render geojson: @plaque }
      format.csv do
        @plaques = []
        @plaques << @plaque
        send_data(
          "\uFEFF#{PlaqueCsv.new(@plaques).build}",
          type: 'text/csv',
          filename: "open-plaque-#{@plaque.id}.csv",
          disposition: 'attachment'
        )
      end
    end
  end

  def new
    @plaque = Plaque.new(language_id: 1)
    @plaque.photos.build
    @countries = Country.alphabetically
    @languages = Language.order('plaques_count DESC nulls last')
    @common_colours = Colour.common.order(plaques_count: :desc)
    @other_colours = Colour.uncommon.alphabetically
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
    @plaque = Plaque.new(permitted_params)

    # early intervention to reject spam messages
    redirect_to plaques_url and return if params[:plaque][:inscription].include?('http')
    redirect_to plaques_url and return if params[:plaque][:inscription].include?('href')
    redirect_to plaques_url and return if params[:plaque][:inscription].blank?
    redirect_to plaques_url and return if params[:plaque][:inscription].start_with?('1') && params[:plaque][:inscription].to_s.size < 10
    redirect_to plaques_url and return if params[:plaque][:inscription].to_s.size < 8
    redirect_to plaques_url and return if params[:area] == 'New York' && params[:plaque][:country] != '13'
    country = if params[:plaque][:country].blank?
                Country.uk
              else
                Country.find(params[:plaque][:country])
              end
    if params[:area_id] && !params[:area_id].blank?
      area = Area.find(params[:area_id])
      raise 'ERROR' if area.country_id != country.id and return
    elsif params[:area] && !params[:area].blank?
      area = country.areas.find_by_name(params[:area])
      area ||= country.areas.find_by_slug(params[:area].strip.downcase.tr(' ', '_'))
      area ||= country.areas.create!(name: params[:area])
    end
    @plaque.area = area

    unless params[:organisation_name].empty? || params[:organisation_name].downcase == 'none' || params[:organisation_name].downcase == 'unknown'
      organisation = Organisation.where(name: params[:organisation_name]).first_or_create
      @plaque.organisations << organisation if organisation.valid?
    end

    if @plaque.save
      flash[:notice] = 'Thanks for adding this plaque.'
      redirect_to plaque_path(@plaque)
    else
      params[:checked] = 'true'
      @plaque.photos.build if @plaque.photos.empty?
      @countries = Country.alphabetically
      @languages = Language.order('plaques_count DESC nulls last')
      @common_colours = Colour.common.order(plaques_count: :desc)
      @other_colours = Colour.uncommon.alphabetically
      render :new
    end
  end

  def update
    if params[:streetview_url]
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
      if @plaque.update(permitted_params)
        flash[:notice] = 'Plaque was successfully updated.'
        format.html { redirect_to(@plaque) }
        format.xml  { head :ok }
      else
        format.html { render :edit }
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

  # access helpers from within controller
  class Helper
    include Singleton
    include PlaquesHelper
  end

  private

  def find
    @plaque = Plaque.find(params[:id])
  end

  def permitted_params
    params.require(:plaque).permit(
      :address,
      :area,
      :area_id,
      :colour_id,
      :country,
      :description,
      'erected_at(1i)',
      'erected_at(2i)',
      'erected_at(3i)',
      :erected_at_string,
      :inscription,
      :inscription_in_english,
      :inscription_is_stub,
      :is_accurate_geolocation,
      :is_current,
      :language_id,
      :latitude,
      :longitude,
      :notes,
      :organisation_name,
      :organisation_id,
      :other_colour_id,
      :series_id,
      :series_ref
    )
  end
end
