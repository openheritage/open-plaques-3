class PeopleAliveInController < ApplicationController

  def index
    @counts = Person.count(:born_on)
    respond_to do |format|
      format.html
      format.json { render json: @counts }
    end
  end

  def show
    year = params[:id].to_i
    raise ActiveRecord::RecordNotFound if year.blank?
    raise ActiveRecord::RecordNotFound if year < 1000
    raise ActiveRecord::RecordNotFound if year > Date.today.year
    @year = Date.parse(year.to_s + "-01-01")
    @people = Person
		  .where(['born_on between ? and ? and died_on between ? and ?', @year - 120.years, @year, @year, @year + 120.years])
		  .preload(:roles, :main_photo)
      .order([:born_on, :surname_starts_with, :name])
      .to_a
    @people.reject! {|subject| !subject.person? }
    respond_to do |format|
      format.html { render "people/alive_in/show" }
      format.json { render json: @people }
    end
  end

end
