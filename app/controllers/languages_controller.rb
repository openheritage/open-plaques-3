class LanguagesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index]

  before_filter :find_language, :only => [:edit, :update]

  def index
    @languages = Language.all
  end

  def new
    @language = Language.new
  end

  def create
    @language = Language.new(params[:language])
    @language.save
    redirect_to languages_path
  end

  def update
    if @language.update_attributes(params[:language])
      redirect_to languages_path
    else
      render :edit
    end
  end

  protected

    def find_language
      @language = Language.find_by_alpha2!(params[:id])
    end

end
