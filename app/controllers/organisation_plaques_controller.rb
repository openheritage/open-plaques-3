class OrganisationPlaquesController < ApplicationController

  before_action :find, only: [:show]

  def show
    begin
      set_meta_tags open_graph: {
        title: "Open Plaques Organisation #{@organisation.name}",
        description: @organisation.description,
      }
      @main_photo = @organisation.main_photo
      set_meta_tags twitter: {
        title: "Open Plaques Organisation #{@organisation.name}",
        image: {
          _: @main_photo ? @main_photo.file_url : view_context.root_url[0...-1] + view_context.image_path("openplaques.png"),
          width: 100,
          height: 100,
        }
      }
    rescue
    end
    zoom = params[:zoom].to_i

    @display = 'plaques'
    if zoom > 0
      @plaques = @organisation.plaques.tile(zoom, params[:x].to_i, params[:y].to_i, params[:filter])
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
      format.html { render "organisations/plaques/show" }
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
