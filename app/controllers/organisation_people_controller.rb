class OrganisationPeopleController < ApplicationController

  before_action :find, only: [:show]

  def show
    @plaques = @organisation.plaques
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
    respond_to do |format|
      format.html { render "people/index" }
      format.json { render json: @people }
      format.geojson { render geojson: @people }
      format.csv {
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

    def find
      @organisation = Organisation.find_by_slug!(params[:organisation_id])
    end

end
