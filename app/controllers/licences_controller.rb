class LicencesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authorisation_required, :except => [:index, :show]
  before_filter :find, :only => [:show]

  def index
    @licences = Licence.all
    @licences = @licences.sort_by { |p| 1 - p.photos.count }
    respond_to do |format|
      format.html
      format.json { render :json => @licences }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render :json => @licence }
    end
  end

  protected

    def find
      @licence = Licence.find(params[:id])
    end

end
