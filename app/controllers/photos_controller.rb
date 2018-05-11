class PhotosController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show, :update, :create]
  before_action :authenticate_admin!, only: :destroy
  before_action :find, only: [:destroy, :edit, :show, :update]
  before_action :get_licences, only: [:new, :create, :edit]

  def index
    @photos = Photo.order(id: :desc).paginate(page: params[:page], per_page: 200)
    respond_to do |format|
      format.html
      format.json { render json: @photos }
      format.geojson { render geojson: @photos.geolocated }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @photo }
      format.geojson { render geojson: @photo }
    end
  end

  def update
    respond_to do |format|
      if @photo.update_attributes(photo_params)
        flash[:notice] = 'Photo was successfully updated.'
      else
        flash[:notice] = @photo.errors
      end
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def new
    @photo = Photo.new
  end

  def create
    @photo = Photo.new(photo_params)
    @photo.populate
    if @photo.errors.empty?
      @already_existing_photo = Photo.find_by_file_url @photo.file_url
      @already_existing_photo = Photo.find_by_file_url(@photo.file_url.gsub("https","http")) if !@already_existing_photo
      if @already_existing_photo
        @photo = @already_existing_photo
        @photo.update_attributes(photo_params)
      end
      @photo.save ? flash[:notice] = 'Photo was successfully updated.' : flash[:notice] = @photo.errors.full_messages.to_sentence
    else
      flash[:notice] = @photo.errors.full_messages.to_sentence
    end
    redirect_back(fallback_location: root_path)
  end

  def edit
    @plaques = @photo.nearest_plaques
  end

  def destroy
    @plaque = @photo.plaque
    @person = @photo.person
    @photo.destroy
    redirect_to @plaque ? plaque_photos_path(@plaque) : @person ? edit_person_path(@person) : photos_path()
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
        :clone_id,
        :description,
        :file_url,
        :latitude,
        :licence_id,
        :longitude,
        :of_a_plaque,
        :person_id,
        :photographer,
        :photographer_url,
        :plaque_id,
        :shot,
        :streetview_url,
        :subject,
        :thumbnail,
        :url)
    end
end
