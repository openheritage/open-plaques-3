class SeriesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :find, :only => [:show, :edit, :update]

  def index
    @series = Series.all
    respond_to do |format|
      format.html
      format.json {
        render :json => @series.as_json()
      }
    end
  end

  def show
    @plaques = @series.plaques
      .order('series_ref asc')
      .paginate(:page => params[:page], :per_page => 20) # Postgres -> NULLS LAST
      .preload(:personal_connections, :language, :photos, :location, area: :country )

    @mean = help.find_mean(@plaques)
    respond_to do |format|
      format.html # show.html.erb
      format.json {
        render :json => @series.as_json()
      }
    end
  end

  def new
    @series = Series.new
  end

  def create
    @series = Series.new(series_params)
    if @series.save
      redirect_to series_path(@series)
    end
  end

  def update
    if @series.update_attributes(series_params)
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

  private

    def series_params
      params.require(:series).permit(
        :name,
        :description)
    end  
end
