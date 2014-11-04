class LocationsController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :find_location, :only => [:show, :edit, :update, :destroy]

  def index
    @locations = Location.find(:all, :order => :name)
  end

  def edit
    @areas = Area.find(:all, :order => :name)
    @countries = Country.find(:all)
  end

  def update
    if @location.update_attributes(params[:location])
      redirect_to location_path(@location)
    else
      render :edit
    end

  end

  def destroy
    @location.destroy
    redirect_to locations_path
  end

  protected

    def find_location
      @location = Location.find(params[:id])
    end

end
