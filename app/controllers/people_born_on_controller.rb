class PeopleBornOnController < ApplicationController

  def index
    @counts = Person.group(:born_on).order(:born_on).count
    respond_to do |format|
      format.html
      format.json { render json: @counts }
    end
  end

  def show
    @year = Date.parse(params[:id] + "-01-01")
    @subjects = Person
      .where(born_on: @year)
      .preload(:roles, :main_photo)
      .order(died_on: :desc)
    @people = @subjects.to_a
    @people.reject! {|subject| !subject.person? }
    respond_to do |format|
      format.html
      format.json { render json: @people }
    end
  end

end
