class PersonPlaquesController < ApplicationController

  def show
    person = Person.find(params[:person_id])
    @plaques = person.plaques
    respond_to do |format|
      format.html { render @plaques }
      format.json { render :json => @plaques.as_json(
        :only => [:id, :inscription, :latitude, :longitude, :is_accurate_geolocation],
        :methods => [:title, :uri, :colour_name]
        )
      }
      format.geojson { render :geojson => @plaques }
    end
  end

end
