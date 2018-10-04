class CountrySubjectsController < ApplicationController

  before_action :find, only: [:show]

  def show
    respond_to do |format|
      #    select people.id, people.name,
      #      (
      #        select count(distinct plaque_id)
      #          FROM personal_connections, plaques, areas
      #          WHERE personal_connections.person_id = people.id
      #		    AND personal_connections.plaque_id = plaques.id
      #		    AND plaques.area_id = areas.id
      #		    AND areas.country_id = 1
      #      ) as plaques_count
      # from people
      # order by plaques_count desc
#      format.html { render "countries/subjects/show" }
      format.csv {
        @people = people(@plaques)
        @plaques = @country.plaques.connected
        send_data(
          "\uFEFF#{PersonCsv.new(@people).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@country.name}-subjects-#{Date.today.to_s}.csv",
          disposition: 'attachment'
        )
      }
    end
  end

  protected

    def people(plaques)
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
