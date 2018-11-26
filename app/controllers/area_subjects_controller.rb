class AreaSubjectsController < ApplicationController

  before_action :find_country, only: [:show]
  before_action :find, only: [:show]

  def show
    respond_to do |format|
      format.html {
        @plaques_count = @area.plaques.size
        @uncurated_count = @area.plaques.unconnected.size
        @curated_count = @plaques_count - @uncurated_count
        @percentage_curated = ((@curated_count.to_f / @plaques_count.to_f) * 100).to_i
        query = "SELECT people.gender, count(distinct person_id) as subject_count
          FROM personal_connections, plaques, areas, people
          WHERE areas.id = #{@area.id}
          AND areas.id = plaques.area_id
          AND plaques.id = personal_connections.plaque_id
          AND personal_connections.person_id = people.id
          GROUP BY people.gender"
        @gender = ActiveRecord::Base.connection.execute(query)
        @gender = @gender.map{|attributes| OpenStruct.new(attributes)}
        @subject_count = @gender.inject(0){|sum, g| sum + g.subject_count }
        @people = []
        render 'areas/subjects/show'
      }
      format.csv {
        @plaques = @area.plaques.connected
        @people = people(@plaques)
        send_data(
          "\uFEFF#{PersonCsv.new(@people).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@area.name}-subjects-#{Date.today.to_s}.csv",
          disposition: 'attachment'
        )
      }
    end
  end

  protected

  def people(plaques)
    @people = []
    plaques.each do |p|
      p.people.each do |per|
        per.define_singleton_method(:plaques_count) do
          1
        end
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
