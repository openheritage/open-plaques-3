class PhotosController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show, :update, :create]
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
    respond_to do |format|
      if @photo.update_attributes(photo_params)
        flash[:notice] = 'Photo was successfully updated.'
        format.html { redirect_to :back }
        format.xml  { head :ok }
      else
        format.html { render "edit" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
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

  	def photo_params
      params.require(:photo).permit(
        :of_a_plaque,
        :url,
        :file_url,
        :photographer,
        :photographer_url,
        :licence_id,
        :plaque_id,
        :person_id,
        :shot
      )
	end
end
