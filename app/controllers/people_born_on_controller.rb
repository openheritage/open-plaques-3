class PeopleBornOnController < ApplicationController

  def index
    @counts = Person.count(:born_on, :group => 'born_on', :order => 'born_on')
  end

  def show
    @year = Date.parse(params[:id] + "-01-01")
    @people = Person.find(:all, :conditions => {:born_on => @year}, :order => :died_on)
    respond_to do |format|
      format.html
      format.kml { render "plaques/show" }
      format.xml { render :xml => @people }
      format.json { render :json => @people }
    end
  end

end
