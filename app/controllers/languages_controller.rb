class LanguagesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index]
  before_filter :find, :only => [:edit, :update]

  def index
    @languages = Language.all.most_plaques_order
    respond_to do |format|
      format.html
      format.json { render :json => @languages }
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

  def update
    if @language.update_attributes(language_params)
      redirect_to languages_path
    else
      render :edit
    end
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
