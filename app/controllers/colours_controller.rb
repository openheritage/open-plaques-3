# control colours
class ColoursController < ApplicationController
  before_action :authenticate_admin!, only: :destroy
  before_action :authenticate_user!, except: :index

  def new
    @colour = Colour.new
  end

  def create
    @colour = Colour.new(permitted_params)
    @colour.save
    redirect_to colours_path
  end

  private

  def permitted_params
    params.require(:colour).permit(
      :dbpedia_uri,
      :name
    )
  end
end
