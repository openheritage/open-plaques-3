class OrganisationPlaquesController < ApplicationController

  before_action :find, only: [:show]

  def show
    zoom = params[:zoom].to_i

    @display = 'plaques'
    if zoom > 0
      x = params[:x].to_i
      y = params[:y].to_i
      @plaques = @organisation.plaques.tile(zoom, x, y, '')
    elsif params[:data] && params[:data] == "simple"
      @plaques = @organisation.plaques.all(conditions: conditions, order: "created_at DESC", limit: limit)
    elsif params[:data] && params[:data] == "basic"
      @plaques = @organisation.plaques.all(select: [:id, :latitude, :longitude, :inscription])
    elsif (params[:filter] && params[:filter]!='')
      begin
        request.format == 'html' ?
          @plaques = @organisation.plaques.send(params[:filter].to_s).paginate(page: params[:page], per_page: 50)
          : @plaques = @organisation.plaques.send(params[:filter].to_s)
        @display = params[:filter].to_s
      rescue # an unrecognised filter method
        request.format == 'html' ?
          @plaques = @organisation.plaques.paginate(page: params[:page], per_page: 50)
          : @plaques = @organisation.plaques
      end
    else
      request.format == 'html' ?
        @plaques = @organisation.plaques.paginate(page: params[:page], per_page: 50)
        : @plaques = @organisation.plaques
    end
    respond_to do |format|
      format.html { render "organisations/show" }
      format.json { render json: @plaques }
      format.geojson { render geojson: @plaques, parent: @organisation }
      format.csv {
        send_data(
          "\uFEFF#{PlaqueCsv.new(@plaques).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@organisation.slug}-#{Date.today.to_s}.csv",
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
