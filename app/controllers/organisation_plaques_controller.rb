class OrganisationPlaquesController < ApplicationController

  before_filter :find_organisation, :only => [:show]
  respond_to :json

  def show
    zoom = params[:zoom].to_i
    if zoom > 0
      x = params[:x].to_i
      y = params[:y].to_i
      @plaques = @organisation.plaques.tile(zoom, x, y, '')
    elsif params[:data] && params[:data] == "simple"
      @plaques = @organisation.plaques.all(:conditions => conditions, :order => "created_at DESC", :limit => limit)
    elsif params[:data] && params[:data] == "basic"
      @plaques = @organisation.plaques.all(:select => [:id, :latitude, :longitude, :inscription])
    else
      @plaques = @organisation.plaques
    end
    respond_with @plaques do |format|
      format.html { render @plaques }
      format.any(:json, :geojson) { 
        render :json => { 
          type: 'FeatureCollection',
          properties: @organisation.as_json(),
          features: @plaques.geolocated.as_json({:only => [:id, :latitude, :longitude, :inscription]})
        }
      }
    end
  end

  protected

    def find_organisation
      @organisation = Organisation.find_by_slug!(params[:organisation_id])
    end

end
