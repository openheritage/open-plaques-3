class AreaPlaquesController < ApplicationController

  before_action :find, only: [:show]
  respond_to :html, :json, :csv

  def show
    begin
      set_meta_tags open_graph: {
        title: "Open Plaques Area #{@area.name}",
      }
      @main_photo = @area.main_photo
      set_meta_tags twitter: {
        title: "Open Plaques Area #{@area.name}",
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
      @plaques = @area.plaques.tile(zoom, params[:x].to_i, params[:y].to_i, params[:filter])
    elsif (params[:filter] && params[:filter]!='')
      begin
        request.format.html? ?
          @plaques = @area.plaques.send(params[:filter].to_s).paginate(page: params[:page], per_page: 50)
          : @plaques = @area.plaques.send(params[:filter].to_s).paginate(page: params[:page], per_page: 5000000)
        @display = params[:filter].to_s
      rescue # an unrecognised filter method
        request.format.html? ?
          @plaques = @area.plaques.paginate(page: params[:page], per_page: 50)
          : @plaques = @area.plaques.paginate(page: params[:page], per_page: 5000000)
        @display = 'all'
      end
    else
      request.format.html? ?
        @plaques = @area.plaques.paginate(page: params[:page], per_page: 50)
        : @plaques = @area.plaques.paginate(page: params[:page], per_page: 5000000)
      @display = 'all'
    end
    respond_with @plaques do |format|
      format.html { render 'areas/plaques/show' }
      format.json { render json: @plaques }
      format.geojson { render geojson: @plaques.geolocated, parent: @area }
      format.csv {
        send_data(
          "\uFEFF#{PlaqueCsv.new(@plaques).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@area.slug}-#{Date.today.to_s}.csv",
          disposition: 'attachment'
        )
      }
    end
  end

  protected

    def find
      @country = Country.find_by_alpha2!(params[:country_id])
      @area = @country.areas.find_by_slug!(params[:area_id])
    end

end
