class PersonPlaquesController < ApplicationController

  respond_to :json

  def show
    person = Person.find(params[:person_id])
    @plaques = person.plaques

    respond_with @plaques do |format|
      format.html { render @plaques }
      format.json { render :json => @plaques.as_json(
        :only => [:id, :inscription, :latitude, :longitude, :is_accurate_geolocation],
        :methods => [:title, :uri, :colour_name]
        )
      }
    end
  end

end
