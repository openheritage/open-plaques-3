# control languages
class LanguagesController < ApplicationController
  before_action :authenticate_admin!, only: :destroy
  before_action :authenticate_user!, except: :index

  def new
    @language = Language.new
  end

  def create
    @language = Language.new(permitted_params)
    @language.save
    redirect_to languages_path
  end

  private

  def permitted_params
    params.require(:language).permit(
      :alpha2,
      :name
    )
  end
end
