class ColoursController < ApplicationController

  before_action :authenticate_admin!, only: :destroy
  before_action :authenticate_user!, except: [:index]
  before_action :find, only: [:update]

  def index
    @colours = Colour.all.most_plaques_order
    respond_to do |format|
      format.html
      format.json { render json: @colours }
    end
  end

  def new
    @colour = Colour.new
  end

  def create
    @colour = Colour.new(colour_params)
    @colour.save
    redirect_to colours_path
  end

  protected

    def find
      @colour = Colour.find_by_slug!(params[:id])
    end

  private

    def colour_params
      params.require(:colour).permit(
        :name,
        :dbpedia_uri)
    end
end
