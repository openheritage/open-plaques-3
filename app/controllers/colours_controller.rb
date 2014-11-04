class ColoursController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :find_colour, :only => [:edit, :update]

  def index
    @colours = Colour.all
    respond_to do |format|
      format.html
      format.kml { render "plaques/index"}
      format.osm { render "plaques/index"}
      format.xml { render :xml => @colours }
      format.json { render :json => @colours }
    end
  end

  def show
    begin
      @colour = Colour.find_by_slug!(params[:id])
    rescue
      @colour = Colour.find(params[:id])
      redirect_to(colour_url(@colour.name), :status => :moved_permanently) and return
    end

    @plaques = @colour.plaques.includes(:personal_connections => :person, :location => [:area => :country]).paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html
      format.kml { render "plaques/index" }
      format.osm { render "plaques/index" }
      format.xml  { render :xml => @colour }
      format.json { render :json => @colour }
    end
  end

  def new
    @colour = Colour.new
  end

  def create
    @colour = Colour.new(params[:colour])

    if @colour.save
      redirect_to colour_path(@colour.slug)
    else
      render :new
    end
  end

  def update
    old_slug = @colour.slug

    if @colour.update_attributes(params[:colour])
      redirect_to colour_path(@colour.slug)
    else
      @colour.slug = old_slug
      render :edit
    end
  end

  protected

    def find_colour
      @colour = Colour.find_by_slug!(params[:id])
    end

end
