class ColoursController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index]
  before_filter :find, :only => [:edit, :update]

  def index
    @colours = Colour.all.most_plaques_order
    respond_to do |format|
      format.html
      format.json { render :json => @colours }
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

  def update
    old_slug = @colour.slug
    if @colour.update_attributes(colour_params)
      redirect_to colours_path
    else
      @colour.slug = old_slug
      render :edit
    end
  end

  protected

    def find
      @colour = Colour.find_by_slug!(params[:id])
    end

  private

    def colour_params
      params.require(:colour).permit(
        :name,
        :dbpedia_uri,
      )
    end
end
