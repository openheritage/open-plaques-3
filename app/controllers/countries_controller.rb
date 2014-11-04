class CountriesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :find_country, :only => [:edit, :update]

  def index
    @countries = Country.all(:order => :name)
    @countries.sort! { |a,b| b.plaques.size <=> a.plaques.size }
    respond_to do |format|
      format.html
      format.xml
      format.json { render :json => @countries.as_json }
    end
  end

  def new
    @country = Country.new
  end

  def create
    @country = Country.new(params[:country])
    if @country.save
      redirect_to country_path(@country)
    else
      render :new
    end
  end

  def show
    begin
      @country = Country.find_by_alpha2!(params[:id])
    rescue
      @country = Country.find(params[:id])
      redirect_to(country_url(@country), :status => :moved_permanently) and return
    end
    @areas = @country.areas.all(:order => :name, :include => :country)
    respond_to do |format|
      format.html
      format.xml
      format.json { render :json => @country.as_json }
      format.kml { render "plaques/index" }
      format.osm { render "plaques/index" }
      format.csv { render "plaques/index" }
    end
  end

  def update
    if @country.update_attributes(params[:country])
      redirect_to country_path(@country)
    else
      render :edit
    end
  end

  protected

    def find_country
      @country = Country.find_by_alpha2!(params[:id])
    end

end
