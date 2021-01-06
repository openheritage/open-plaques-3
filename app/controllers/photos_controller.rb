# control photos
class PhotosController < ApplicationController
  before_action :authenticate_user!, except: %i[index show update create]
  before_action :authenticate_admin!, only: :destroy
  before_action :find, only: %i[destroy edit show update]
  before_action :licences, only: %i[new create edit]

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
      flash[:notice] = if @photo.update(permitted_params)
                         'Photo was successfully updated.'
                       else
                         @photo.errors
                       end
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def new
    @photo = Photo.new
  end

  def create
    @photo = Photo.new(permitted_params)
    @photo.populate
    if @photo.errors.empty?
      @already_existing_photo = Photo.find_by_file_url(@photo.file_url)
      @already_existing_photo ||= Photo.find_by_file_url(@photo.file_url.gsub('https', 'http'))
      if @already_existing_photo
        @photo = @already_existing_photo
        @photo.update(permitted_params)
      end
      flash[:notice] = if @photo.save
                         'Photo was successfully updated.'
                       else
                         @photo.errors.full_messages.to_sentence
                       end
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
    if @plaque
      redirect_to plaque_photos_path(@plaque)
    elsif @person
      redirect_to edit_person_path(@person)
    else
      redirect_to photos_path
    end
  end

  protected

  def find
    @photo = Photo.find(params[:id])
  end

  def licences
    @licences = Licence.alphabetically
  end

  private

  def help
    Helper.instance
  end

  # access helpers from controller
  class Helper
    include Singleton
    include PlaquesHelper
  end

  def permitted_params
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
      :url
    )
  end
end
