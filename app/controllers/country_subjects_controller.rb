require 'ostruct'

class CountrySubjectsController < ApplicationController
  before_action :find, only: [:show]

  def show
    respond_to do |format|
      format.html do
        @plaques_count = @country.plaques.count # size is 0
        @uncurated_count = @country.plaques.unconnected.size
        @curated_count = @plaques_count - @uncurated_count
        @percentage_curated = ((@curated_count.to_f / @plaques_count) * 100).to_i
        @results = ActiveRecord::Base.connection.execute(
          "SELECT people.id, people.name, people.gender,
            (
              SELECT count(distinct plaque_id)
              FROM personal_connections, plaques, areas

              WHERE personal_connections.person_id = people.id
              AND personal_connections.plaque_id = plaques.id
              AND plaques.area_id = areas.id
              AND areas.country_id = #{@country.id}
            ) as plaques_count
            FROM people
            ORDER BY plaques_count desc
            LIMIT 50"
        )
        @top = @results.reject{|p| p['plaques_count'] < 1}.map{|attributes| OpenStruct.new(attributes)}
        @gender = ActiveRecord::Base.connection.execute(
          "SELECT people.gender, count(distinct person_id) as subject_count
            FROM areas, plaques, personal_connections, people
            WHERE areas.country_id = #{@country.id}
            AND areas.id = plaques.area_id
            AND plaques.id = personal_connections.plaque_id
            AND personal_connections.person_id = people.id
            GROUP BY people.gender"
        )
        @gender = @gender.map{|attributes| OpenStruct.new(attributes)}
        @subject_count = @gender.inject(0){|sum, g| sum + g.subject_count }
        render 'countries/subjects/top'
      end
      format.csv do
        @plaques = @country.plaques.connected
        @people = people(@plaques)
        send_data(
          "\uFEFF#{PersonCsv.new(@people).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@country.name}-subjects-#{Date.today}.csv",
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
          per.define_singleton_method(:plaques_count) do
            1
          end
          @people << per
        end
      end
      @people.uniq
    end

    def find
      @country = Country.find_by_alpha2!(params[:country_id])
    end
end
