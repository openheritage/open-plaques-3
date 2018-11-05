class OrganisationSubjectsController < ApplicationController

  before_action :find, only: [:show]

  def show
    respond_to do |format|
      format.html {
        @uncurated_count = @organisation.plaques.unconnected.count
        @plaques = @organisation.plaques.connected#.paginate(page: params[:page], per_page: 20)
        @people = people(@plaques)
        @total = @people.count + @uncurated_count
        @type_counts = @people.map {|p| p.type }.group_by(&:itself).map {|k,v| [k, v.size] }
        @type_counts << ['uncurated', @uncurated_count]
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
