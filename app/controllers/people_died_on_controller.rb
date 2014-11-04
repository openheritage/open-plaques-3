class PeopleDiedOnController < ApplicationController

  def index
    @counts = Person.count(:died_on, :group => 'died_on', :order => 'died_on')
  end

  def show
    @year = Date.parse(params[:id] + "-01-01")
    @people = Person.find(:all, :conditions => {:died_on => @year}, :order => :born_on)
    respond_to do |format|
      format.html
      format.kml { render "plaques/show" }
      format.xml { render :xml => @people }
      format.json { render :json => @people }
    end
  end

end
