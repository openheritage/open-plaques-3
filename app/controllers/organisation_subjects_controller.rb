class OrganisationSubjectsController < ApplicationController

  before_action :find, only: [:show]

  def show
    respond_to do |format|
      format.html {
        @plaques_count = @organisation.plaques.count # size is 0
        @uncurated_count = @organisation.plaques.unconnected.size
        @curated_count = @plaques_count - @uncurated_count
        @percentage_curated = ((@curated_count.to_f / @plaques_count) * 100).to_i
        query = "SELECT people.gender, count(distinct person_id) as subject_count
          FROM sponsorships, personal_connections, people
          WHERE sponsorships.organisation_id = #{@organisation.id}
          AND sponsorships.plaque_id = personal_connections.plaque_id
          AND personal_connections.person_id = people.id
          GROUP BY people.gender"
        @gender = ActiveRecord::Base.connection.execute(query)
        @gender = @gender.map{|attributes| OpenStruct.new(attributes)}
        @subject_count = @gender.inject(0){|sum, g| sum + g.subject_count }
        @people = []
      render 'organisations/subjects/show'
      }
      format.json { render json: @people }
      format.geojson { render geojson: @people }
      format.csv {
        @plaques = @organisation.plaques.connected
        @people = people(@plaques)
        send_data(
          "\uFEFF#{PersonCsv.new(@people).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@organisation.slug}-subjects-#{Date.today.to_s}.csv",
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

    def find
      @organisation = Organisation.find_by_slug!(params[:organisation_id])
    end

end
