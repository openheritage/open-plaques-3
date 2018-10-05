require 'ostruct'

class CountrySubjectsController < ApplicationController
  before_action :find, only: [:show]

  def show
    respond_to do |format|
      format.html do
        query = "SELECT people.id, people.name,
                (
                  SELECT count(distinct plaque_id)
                  FROM personal_connections, plaques, areas

                  WHERE personal_connections.person_id = people.id
                  AND personal_connections.plaque_id = plaques.id
                  AND plaques.area_id = areas.id
                  AND areas.country_id = #{@country.id}
                ) as plaques_count
                FROM people
                ORDER BY plaques_count desc"
        @results = ActiveRecord::Base.connection.execute(query)
        @top = @results.reject{|p| p['plaques_count'] < 1}.map{|attributes| OpenStruct.new(attributes)}
        render 'countries/subjects/top'
      end
      format.csv do
        @people = people(@plaques)
        @plaques = @country.plaques.connected
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

    def people(_plaques)
      @people = []
      @plaques.each do |p|
        p.people.each do |per|
          per.define_singleton_method(:plaques_count) do
            1
          end
          @people << per
        end
      end
      @people.uniq!
    end

    def find
      @country = Country.find_by_alpha2!(params[:country_id])
    end
end
