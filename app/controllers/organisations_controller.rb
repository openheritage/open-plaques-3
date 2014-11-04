class OrganisationsController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :find_organisation, :only => [:edit, :update]

  def index
    if params[:name_starts_with]
      limit = params[:limit] ? params[:limit] : 5
      @organisations = Organisation.name_contains(params[:name_starts_with]).limit(limit).most_plaques_order
    else
      @organisations = Organisation.all(:order => :name)
    end
    respond_to do |format|
      format.html
      format.kml {
        @parent = @organisations
        render "plaques/index"
      }
      format.xml
      format.json { render :json => @organisations }
    end
  end

  def show
    begin
      if (params[:id]=="oxfordshire_blue_plaques_scheme") 
        params[:id] = "oxfordshire_blue_plaques_board"
        redirect_to(organisation_path(params[:id])) and return
      end
      @organisation = Organisation.find_by_slug!(params[:id])
    rescue
      @organisation = Organisation.find(params[:id])
      redirect_to(organisation_path(@organisation.slug), :status => :moved_permanently) and return
    end
    @sponsorships = @organisation.sponsorships.paginate(:page => params[:page], :per_page => 50)
    @mean = @organisation
    @zoom = @organisation.zoom
    respond_to do |format|
      format.html
      format.kml {
        @plaques = @organisation.plaques
        render "plaques/index"
      }
      format.osm { 
        @plaques = @organisation.plaques
        render "plaques/index" 
      }
      format.xml
      format.json {
      if request.env["HTTP_USER_AGENT"].include? "bot"
        puts "** rejecting a bot call to json by "+env["HTTP_USER_AGENT"]
        render :json => {:error => "no-bots"}.to_json, :status => 406
      else
        conditions = {}

        # Bounding-box query
        if params[:box]
          # TODO: Should really do some validation here...
          coords = params[:box][1,params[:box].length-2].split("],[")
          top_left = coords[0].split(",")
          bottom_right = coords[1].split(",")
          conditions[:latitude] = bottom_right[0].to_s..top_left[0].to_s
          conditions[:longitude] = top_left[1].to_s..bottom_right[1].to_s
        end
        if params[:limit] && params[:limit].to_i <= 2000
          limit = params[:limit]
        elsif params[:limit]
          limit = 2000
        else
          limit = 20
        end
        @plaques = Plaque.joins(:sponsorships).where('sponsorships.organisation_id' => @organisation.id).all(:conditions => conditions, :order => "created_at DESC", :limit => limit)
        render :json => @plaques.as_json(:only => [:id, :latitude, :longitude, :inscription],
          :methods => [:uri, :title, :colour_name, :machine_tag, :thumbnail_url])
#        render :json => @organisation.sponsorships(:conditions => conditions, :limit => limit).as_json
      end
      }
    end
  end

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(params[:organisation])
    if @organisation.save
      redirect_to organisation_path(@organisation.slug)
    else
      render :new
    end
  end

  def update
    old_slug = @organisation.slug
    if @organisation.update_attributes(params[:organisation])
      flash[:notice] = 'Updates to organisation saved.'
      redirect_to organisation_path(@organisation.slug)
    else
      @organisation.slug = old_slug
      render "edit"
    end
  end

  protected

    def find_organisation
      @organisation = Organisation.find_by_slug!(params[:id])
      if (!@organisation.geolocated? && @organisation.plaques.geolocated.size > 3)
        @organisation.save
      end
    end

    def help
      Helper.instance
    end

    class Helper
      include Singleton
      include PlaquesHelper
    end

end
