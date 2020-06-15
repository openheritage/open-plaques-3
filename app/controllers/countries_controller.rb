# control countries
class CountriesController < ApplicationController
  before_action :authenticate_admin!, only: :destroy
  before_action :authenticate_user!, except: %i[index show]
  before_action :find, only: %i[edit update]
  before_action :streetview_to_params, only: :update

  def index
    @countries = Country.all.to_a
    @countries.delete_if { |x| x.plaques_count.zero? }
    @countries.sort! { |a, b| b.plaques_count <=> a.plaques_count }
    set_meta_tags open_graph: {
      type: :website,
      url: url_for(only_path: false),
      image: view_context.root_url[0...-1] + view_context.image_path('openplaques-icon.png'),
      title: 'countries that have plaques',
      description: 'countries that have plaques'
    }
    set_meta_tags twitter: {
      card: 'summary_large_image',
      site: '@openplaques',
      title: 'countries that have plaques',
      image: {
        _: view_context.root_url[0...-1] + view_context.image_path('openplaques-icon.png'),
        width: 100,
        height: 100
      }
    }
    respond_to do |format|
      format.html
      format.json { render json: @countries }
      format.geojson { render geojson: @countries }
    end
  end

  def new
    @country = Country.new
  end

  def create
    @country = Country.new(permitted_params)
    if @country.save
      redirect_to country_path(@country)
    else
      render :new
    end
  end

  def show
    begin
      @country = Country.find_by_alpha2!(params[:id])
      @areas = @country.areas # .select(:id,:name,:country_id,:slug,:plaques_count)
    rescue
      @country = Country.find(params[:id])
      redirect_to(country_url(@country), status: :moved_permanently) and return
    end
    @plaques_count = @country.plaques.count # size is 0
    @uncurated_count = @country.plaques.unconnected.size
    @curated_count = @plaques_count - @uncurated_count
    @percentage_curated = if @plaques_count > 0
                            ((@curated_count.to_f / @plaques_count) * 100).to_i
                          else
                            0
                          end
    @results = ActiveRecord::Base.connection.execute(
      "SELECT people.id, people.name, people.gender,
        (
          SELECT count(distinct plaque_id)
          FROM personal_connections, plaques, areas
          WHERE personal_connections.person_id = people.id
          AND personal_connections.plaque_id = plaques.id
          AND plaques.area_id = areas.id
          AND areas.country_id = #{@country.id}
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
        WHERE areas.country_id = #{@country.id}
        AND areas.id = plaques.area_id
        AND plaques.id = personal_connections.plaque_id
        AND personal_connections.person_id = people.id
        GROUP BY people.gender"
    )
    @gender = @gender.map { |attributes| OpenStruct.new(attributes) }
    @subject_count = @gender.inject(0) { |sum, g| sum + g.subject_count }
    @gender.append(OpenStruct.new(gender: 'tba', subject_count: @uncurated_count))
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
    respond_to do |format|
      format.html
      format.json { render json: @country }
      format.geojson { render geojson: @country }
    end
  end

  def update
    if @country.update_attributes(permitted_params)
      redirect_to country_path(@country)
    else
      render :edit
    end
  end

  protected

  def find
    @country = Country.find_by_alpha2!(params[:id])
  end

  # access helpers within controller
  class Helper
    include Singleton
    include PlaquesHelper
  end

  def streetview_to_params
    return unless params[:streetview_url]

    point = Helper.instance.geolocation_from params[:streetview_url]
    return unless !point.latitude.blank? && !point.longitude.blank?

    params[:country][:latitude] = point.latitude.to_s
    params[:country][:longitude] = point.longitude.to_s
  end

  private

  def permitted_params
    params.require(:country).permit(
      :alpha2,
      :description,
      :latitude,
      :longitude,
      :name,
      :preferred_zoom_level,
      :streetview_url,
      :wikidata_id
    )
  end
end
