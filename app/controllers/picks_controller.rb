class PicksController < ApplicationController

  before_action :find, only: [:edit, :update, :show, :destroy]

  def index
    @picks = Pick.all
    @todays = Pick.todays
    respond_to do |format|
      format.html
      format.json { render json: @picks }
      format.geojson { render geojson: @picks }
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @pick }
      format.geojson { render geojson: @pick }
    end
  end

  def new
    @picks = Pick.new
  end

  def create
    @pick = Pick.new(pick_params)
    @plaque = Plaque.find(params[:pick][:plaque_id])
    @pick.plaque = @plaque
    @pick.save
    redirect_to picks_path
  end

  def update
    if @pick.update_attributes(pick_params)
      redirect_to pick_path(@pick)
    else
      render :edit
    end
  end

  protected

    def find
      @pick = Pick.find(params[:id])
    end

  private

    def pick_params
      params.require(:pick).permit(
        :plaque_id,
        :description,
        :proposer,
        :feature_on,
        :last_featured,
        :featured_count)
    end

end
