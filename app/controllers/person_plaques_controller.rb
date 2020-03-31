# show people on a plaque
class PersonPlaquesController < ApplicationController
  def show
    @person = Person.find(params[:person_id])
    @plaques = @person.plaques
    respond_to do |format|
      format.html { render 'people/plaques/show' }
      format.json do
        render json: @plaques.as_json(
          only: %i[id inscription latitude longitude is_accurate_geolocation],
          methods: %i[title uri colour_name]
        )
      end
      format.geojson { render geojson: @plaques }
      format.csv do
        send_data(
          "\uFEFF#{PlaqueCsv.new(@plaques).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@person.name}-#{Date.today}.csv",
          disposition: 'attachment'
        )
      end
    end
  end
end
