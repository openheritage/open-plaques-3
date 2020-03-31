# show subjects in an area
class AreaSubjectsController < ApplicationController
  before_action :find_country, only: :show
  before_action :find, only: :show

  def show
    @plaques_count = @area.plaques.size
    @uncurated_count = @area.plaques.unconnected.size
    @curated_count = @plaques_count - @uncurated_count
    @percentage_curated = ((@curated_count.to_f / @plaques_count) * 100).to_i
    query = "SELECT people.gender, count(distinct person_id) as subject_count
      FROM personal_connections, plaques, areas, people
      WHERE areas.id = #{@area.id}
      AND areas.id = plaques.area_id
      AND plaques.id = personal_connections.plaque_id
      AND personal_connections.person_id = people.id
      GROUP BY people.gender"
    @gender = ActiveRecord::Base.connection.execute(query)
    @gender = @gender.map { |attributes| OpenStruct.new(attributes) }
    @subject_count = @gender.inject(0) { |sum, g| sum + g.subject_count }
    @gender.append(OpenStruct.new(gender: 'tba', subject_count: @uncurated_count))
    respond_to do |format|
      format.html do
        @people = @area.people # .paginate(page: params[:page], per_page: 50)
        render 'areas/subjects/show'
      end
      format.json { render json: @area.people }
      format.csv do
        @plaques = @area.plaques.connected
        @people = people(@plaques)
        send_data(
          "\uFEFF#{PersonCsv.new(@people).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@area.name}-subjects-#{Date.today}.csv",
          disposition: 'attachment'
        )
      end
    end
  end

  protected

  def people(plaques)
    @people = []
    plaques.each do |p|
      p.people.each do |per|
        per.define_singleton_method(:plaques_count) { 1 }
        @people << per
      end
    end
    @people.uniq
  end

  def find_country
    @country = Country.find_by_alpha2!(params[:country_id])
  end

  def find
    @area = @country.areas.find_by_slug!(params[:area_id])
  end
end
