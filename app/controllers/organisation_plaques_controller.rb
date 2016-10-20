class OrganisationPlaquesController < ApplicationController

  before_filter :find, only: [:show]

  def show
    zoom = params[:zoom].to_i

    @display = 'plaques'
    if zoom > 0
      x = params[:x].to_i
      y = params[:y].to_i
      @sponsorships = @organisation.plaques.tile(zoom, x, y, '')
    elsif params[:data] && params[:data] == "simple"
      @sponsorships = @organisation.plaques.all(conditions: conditions, order: "created_at DESC", limit: limit)
    elsif params[:data] && params[:data] == "basic"
      @sponsorships = @organisation.plaques.all(select: [:id, :latitude, :longitude, :inscription])
    elsif (params[:filter] && params[:filter]!='')
      begin
        request.format == 'html' ?
          @sponsorships = @organisation.plaques.send(params[:filter].to_s).paginate(page: params[:page], per_page: 50)
          : @sponsorships = @organisation.plaques.send(params[:filter].to_s)
        @display = params[:filter].to_s
      rescue # an unrecognised filter method
        request.format == 'html' ?
          @sponsorships = @organisation.plaques.paginate(page: params[:page], per_page: 50)
          : @sponsorships = @organisation.plaques
      end
    else
      request.format == 'html' ?
        @sponsorships = @organisation.plaques.paginate(page: params[:page], per_page: 50)
        : @sponsorships = @organisation.plaques
    end
    respond_to do |format|
      format.html { render "organisations/show" }
      format.json { render json: @sponsorships }
      format.geojson { render geojson: @sponsorships, parent: @organisation }
    end
  end

  protected

    def find
      @organisation = Organisation.find_by_slug!(params[:organisation_id])
    end

end
