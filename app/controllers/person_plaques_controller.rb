class PersonPlaquesController < ApplicationController

  def show
    @person = Person.find(params[:person_id])
    @plaques = @person.plaques
    respond_to do |format|
      format.html { render "people/plaques/show" }
      format.json { render json: @plaques.as_json(
        only: [:id, :inscription, :latitude, :longitude, :is_accurate_geolocation],
        methods: [:title, :uri, :colour_name]
        )
      }
      format.geojson { render geojson: @plaques }
      format.csv {
        send_data(
          "\uFEFF#{PlaqueCsv.new(@plaques).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@person.name}-#{Date.today.to_s}.csv",
          disposition: 'attachment'
        )
      }
    end
  end

end
