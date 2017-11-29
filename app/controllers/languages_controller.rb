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
    @language = Language.new(language_params)
    @language.save
    redirect_to languages_path
  end

  protected

    def find
      @language = Language.find_by_alpha2!(params[:id])
    end

  private

    def language_params
      params.require(:language).permit(
        :name,
        :alpha2)
    end
end
