class OrganisationPlaquesController < ApplicationController

  before_filter :find, only: [:show]

  def show
    zoom = params[:zoom].to_i
    if zoom > 0
      x = params[:x].to_i
      y = params[:y].to_i
      @plaques = @organisation.plaques.tile(zoom, x, y, '')
    elsif params[:data] && params[:data] == "simple"
      @plaques = @organisation.plaques.all(conditions: conditions, order: "created_at DESC", limit: limit)
    elsif params[:data] && params[:data] == "basic"
      @plaques = @organisation.plaques.all(select: [:id, :latitude, :longitude, :inscription])
    else
      @plaques = @organisation.plaques
    end
    respond_to do |format|
      format.html { render @plaques }
      format.json { render json: @plaques }
      format.geojson { render geojson: @plaques, parent: @organisation }
    end
  end

  protected

    def find
      @organisation = Organisation.find_by_slug!(params[:organisation_id])
    end

end
