class SeriesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :find, :only => [:show, :edit, :update]

  def index
    @series = Series.all(:order => :name)
  end

  def show
    @plaques = @series.plaques.paginate(:page => params[:page], :per_page => 20, :order => 'series_ref ASC') # Postgres -> NULLS LAST
    @mean = help.find_mean(@plaques)
    respond_to do |format|
      format.html # show.html.erb
      format.kml { render "plaques/index" }
      format.xml { render "plaques/index" }
      format.json {
        render :json => @series.plaques
      }
    end
  end

  def new
    @series = Series.new
  end

  def create
    @series = Series.new(params[:series])
    if @series.save
      redirect_to series_path(@series)
    end
  end

  def update
    if @series.update_attributes(params[:series])
      redirect_to series_path(@series)
    else
      render :edit
    end
  end

  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include PlaquesHelper
  end
  
  protected

    def find
      @series = Series.find(params[:id])
    end
  
end
