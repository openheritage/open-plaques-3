class LicencesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authorisation_required, :except => [:index, :show]

  def index
    @licences = Licence.all
    respond_to do |format|
      format.html
      format.json { render :json => @licences }
    end
  end

  def show
    @licence = Licence.find(params[:id])
  end

end
