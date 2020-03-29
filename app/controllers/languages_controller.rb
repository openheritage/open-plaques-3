# control languages
class LanguagesController < ApplicationController
  before_action :authenticate_admin!, only: :destroy
  before_action :authenticate_user!, except: [:index]
  before_action :find, only: [:update]

  def index
    @languages = Language.all.most_plaques_order
    respond_to do |format|
      format.html
      format.json { render json: @languages }
    end
  end

  def new
    @language = Language.new
  end

  def create
    @language = Language.new(permitted_params)
    @language.save
    redirect_to languages_path
  end

  protected

  def find
    @language = Language.find_by_alpha2!(params[:id])
  end

  private

  def permitted_params
    params.require(:language).permit(
      :alpha2,
      :name
    )
  end
end
