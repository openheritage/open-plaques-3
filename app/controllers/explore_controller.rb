class ExploreController < ApplicationController

  def show
    respond_to do |format|
      format.html
      format.json { render :json => {:page => "Explore"} }
    end
  end

end
