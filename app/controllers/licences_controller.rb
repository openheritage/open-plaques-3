class LicencesController < ApplicationController

  def index
    @licences = Licence.all
    @licences = @licences.sort_by { |p| 1 - p.photos.count }
    respond_to do |format|
      format.html
      format.json { render json: @licences }
    end
  end

end
