class PhotosController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :show, :update, :create]
  before_filter :authenticate_admin!, :only => :destroy
  before_filter :find, :only => [:destroy, :edit, :show, :update]
  before_filter :get_licences, :only => [:new, :create, :edit]

  def index
    @photos = Photo.order(id: :desc).paginate(:page => params[:page], :per_page => 200)
    respond_to do |format|
      format.html
      format.json { render :json => @photos }
      format.geojson { render :geojson => @photos.geolocated }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render :json => @photo }
      format.geojson { render :geojson => @photo }
    end
  end

  def update
    if (params[:streetview_url] && params[:streetview_url]!='')
      point = help.geolocation_from params[:streetview_url]
      if !point.latitude.blank? && !point.longitude.blank?
        params[:photo][:latitude] = point.latitude
        params[:photo][:longitude] = point.longitude
      end
    end
    respond_to do |format|
      if @photo.update_attributes(photo_params)
        flash[:notice] = 'Photo was successfully updated.'
        format.html { redirect_to :back }
      else
        format.html { render "edit" }
      end
    end
  end

  def new
    @photo = Photo.new
  end

  def create
    @photo = Photo.new(photo_params)
    @photo.wikimedia_data
    @photo.save
    redirect_to :back
  end

  def edit
    if (!@photo.linked?)
      distance = 0.01
      @plaques = Plaque.where(longitude: (@photo.longitude.to_f - distance)..(@photo.longitude.to_f + distance),
      latitude: (@photo.latitude.to_f - distance)..(@photo.latitude.to_f + distance) )
    end
  end

  def destroy
    @plaque = @photo.plaque
    @photo.destroy
    redirect_to plaque_path(@plaque)
  end

  protected

    def find
      @photo = Photo.find(params[:id])
    end

    def get_licences
      @licences = Licence.order(:name)
    end

  private

    def help
      Helper.instance
    end

    class Helper
      include Singleton
      include PlaquesHelper
    end

  	def photo_params
      params.require(:photo).permit(
        :of_a_plaque,
        :subject,
        :description,
        :url,
        :file_url,
        :photographer,
        :photographer_url,
        :licence_id,
        :plaque_id,
        :person_id,
        :shot,
        :latitude,
        :longitude,
        :streetview_url)
    end
end
