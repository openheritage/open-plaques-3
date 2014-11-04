class PeopleAliveInController < ApplicationController

  def index
    @counts = Person.count(:born_on)
  end

  def show
    year = params[:id].to_i
    raise ActiveRecord::RecordNotFound if year.blank?
    raise ActiveRecord::RecordNotFound if year < 1000
    raise ActiveRecord::RecordNotFound if year > Date.today.year

    @year = Date.parse(year.to_s + "-01-01")
    @people = Person.find(:all, :conditions => ['born_on between ? and ? and died_on between ? and ?', @year - 120.years, @year, @year, @year + 120.years], :order => [:born_on, :surname_starts_with, :name])
    respond_to do |format|
      format.html
      format.kml { render "plaques/show" }
      format.xml { render :xml => @people }
      format.json { render :json => @people }
    end
  end

end
