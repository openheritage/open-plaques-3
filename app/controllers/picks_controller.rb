class PicksController < ApplicationController

  before_filter :find_pick, :only => [:edit, :update, :show, :destroy]
  respond_to :json
  
  def index
    @picks = Pick.all
    respond_to do |format|
      format.html
      format.json { render :json => @picks }
    end
  end

  def new
    @picks = Pick.new
  end

  def create
    @pick = Pick.new(params[:pick])
    @plaque = Plaque.find(params[:pick][:plaque_id])
    @pick.plaque = @plaque
    @pick.save
    redirect_to picks_path
  end

  def destroy
    @pick.destroy
    redirect_to picks_path
  end

  def update
    if @pick.update_attributes(params[:pick])
      redirect_to pick_path(@pick)
    else
      render :edit
    end
  end

  protected

    def find_pick
      @pick = Pick.find(params[:id])
    end

end
