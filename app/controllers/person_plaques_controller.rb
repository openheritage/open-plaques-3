class PersonPlaquesController < ApplicationController

  respond_to :json

  def show
    person = Person.find(params[:person_id])
    @plaques = person.plaques

    respond_with @plaques do |format|
      format.json { render :json => @plaques.as_json(
        :only => [:id, :latitude, :longitude, :inscription],
        :methods => [:title, :uri, :colour_name]
        )
      }
      format.html { render @plaques }
    end
  end

end
