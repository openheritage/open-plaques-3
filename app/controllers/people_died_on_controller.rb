class PeopleDiedOnController < ApplicationController

  def index
    @counts = Person.group(:died_on).order(died_on: :desc).count
    respond_to do |format|
      format.html
      format.json { render :json => @counts }
    end
  end

  def show
    @year = Date.parse(params[:id] + "-01-01")
    @people = Person
      .where(:died_on => @year)
      .preload(:roles, :main_photo)
      .order(born_on: :asc)
      .to_a
    @people.reject! {|subject| !subject.person? }
    respond_to do |format|
      format.html
      format.json { render :json => @people }
    end
  end

end
