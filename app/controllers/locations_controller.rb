class LocationsController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :find, :only => [:show, :edit, :update, :destroy]

  def index
    @locations = Location.order(:name)
  end

  def edit
    @areas = Area.order(:name)
    @countries = Country.all
  end

  def update
    if @location.update_attributes(location_params)
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

    def find
      @location = Location.find(params[:id])
    end

  private

    def location_params
      params.require(:location).permit(
        :name,
        :area_id,
      )
    end

end
