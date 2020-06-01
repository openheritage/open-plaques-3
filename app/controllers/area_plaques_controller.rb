# control plaques in an area
class AreaPlaquesController < ApplicationController
  before_action :find, only: :show
  respond_to :html, :json, :csv

  def show
    begin
      set_meta_tags open_graph: {
        title: "Open Plaques Area #{@area.name}"
      }
      @main_photo = @area.main_photo
      set_meta_tags twitter: {
        title: "Open Plaques Area #{@area.name}",
        image: {
          _: @main_photo ? @main_photo.file_url : view_context.root_url[0...-1] + view_context.image_path('openplaques.png'),
          width: 100,
          height: 100
        }
      }
    rescue
    end
    zoom = params[:zoom].to_i
    @display = 'plaques'
    if zoom.positive?
      @plaques = @area.plaques.tile(zoom, params[:x].to_i, params[:y].to_i, params[:filter])
    elsif params[:filter] && params[:filter] != ''
      begin
        @plaques = if request.format.html?
                     @area.plaques.send(params[:filter].to_s).paginate(page: params[:page], per_page: 50)
                   else
                     @area.plaques.send(params[:filter].to_s).paginate(page: params[:page], per_page: 5_000_000)
                   end
        @display = params[:filter].to_s
      rescue # an unrecognised filter method
        @plaques = if request.format.html?
                     @area.plaques.paginate(page: params[:page], per_page: 50)
                   else
                     @area.plaques.paginate(page: params[:page], per_page: 5_000_000)
                   end
        @display = 'all'
      end
    else
      @plaques = if request.format.html?
                   @area.plaques.paginate(page: params[:page], per_page: 50)
                 else
                   @area.plaques.paginate(page: params[:page], per_page: 5_000_000)
                 end
      @display = 'all'
    end
    respond_with @plaques do |format|
      format.html { 
        @plaques_count = @area.plaques.count
        @uncurated_count = @area.plaques.unconnected.size
        @curated_count = @plaques_count - @uncurated_count
        @percentage_curated = ((@curated_count.to_f / @plaques_count) * 100).to_i
        @results = ActiveRecord::Base.connection.execute(
          "SELECT people.id, people.name, people.gender,
            (
              SELECT count(distinct plaque_id)
              FROM personal_connections, plaques, areas
              WHERE personal_connections.person_id = people.id
              AND personal_connections.plaque_id = plaques.id
              AND plaques.area_id = #{@area.id}
            ) as plaques_count
            FROM people
            ORDER BY plaques_count desc
            LIMIT 10"
        )
        @top = @results
               .reject { |p| p['plaques_count'] < 2 }
               .map { |attributes| OpenStruct.new(attributes) }
        @top.each_with_index { |p, i| p['rank'] = i + 1 }
        puts "top #{@top.size}"
        @gender = ActiveRecord::Base.connection.execute(
          "SELECT people.gender, count(distinct person_id) as subject_count
            FROM areas, plaques, personal_connections, people
            WHERE areas.id = #{@area.id}
            AND plaques.area_id = #{@area.id}
            AND plaques.id = personal_connections.plaque_id
            AND personal_connections.person_id = people.id
            GROUP BY people.gender"
        )
        @gender = @gender.map { |attributes| OpenStruct.new(attributes) }
        @subject_count = @gender.inject(0) { |sum, g| sum + g.subject_count }
        @gender.append(OpenStruct.new(gender: 'tba', subject_count: @uncurated_count)) if @uncurated_count > 0
        @gender.each do |g|
          case g['gender']
          when 'f'
            g['gender'] = 'female'
          when 'm'
            g['gender'] = 'male'
          when 'n'
            g['gender'] = 'inanimate'
          when 'u'
            g['gender'] = 'not set'
          when 'tba'
            g['gender'] = 'to be advised'
          end
          if g['subject_count'] > 0
            g['percent'] = (100 * g.subject_count / (@subject_count.to_f + @uncurated_count)).to_i
          else
            g['percent'] = 0
          end
        end
        puts "gender #{@gender}"
        render 'areas/plaques/show'
      }
      format.json { render json: @plaques }
      format.geojson { render geojson: @plaques.geolocated, parent: @area }
      format.csv do
        send_data(
          "\uFEFF#{PlaqueCsv.new(@plaques).build}",
          type: 'text/csv',
          filename: "open-plaques-#{@area.slug}-#{Date.today}.csv",
          disposition: 'attachment'
        )
      end
    end
  end

  protected

  def find
    @country = Country.find_by_alpha2!(params[:country_id])
    @area = @country.areas.find_by_slug!(params[:area_id])
  end
end
