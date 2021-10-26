# control organisations
class OrganisationsController < ApplicationController
  before_action :authenticate_admin!, only: :destroy
  before_action :authenticate_user!, except: %i[autocomplete index show]
  before_action :find, only: %i[edit update]
  before_action :find_languages, only: %i[edit create]

  def index
    @organisation_count = Organisation.all.count
    @organisations = Organisation
                     .all
                     .select(:language_id, :name, :slug, :sponsorships_count)
                     .alphabetically
                     .paginate(page: params[:page], per_page: 50)
    @top_ten = Organisation
               .all
               .select(:name, :slug, :sponsorships_count)
               .by_popularity
               .limit(10)
    respond_to do |format|
      format.html
      format.json { render json: @organisations }
      format.geojson do
        @organisations = Organisation.all.alphabetically
        render geojson: @organisations
      end
    end
  end

  def autocomplete
    limit = params[:limit] || 5
    @organisations = Organisation.select(:id, :name).name_is(params[:contains] || params[:starts_with]).limit(limit)
    @organisations += Organisation.select(:id, :name).name_starts_with(params[:contains] || params[:starts_with]).alphabetically.limit(limit)
    @organisations += Organisation.select(:id, :name).name_contains(params[:contains]).alphabetically.limit(limit) if params[:contains]
    @organisations.uniq!
    render json: @organisations.as_json(only: %i[id name])
  end

  def show
    params[:id].gsub!('oxfordshire_blue_plaques_scheme', 'oxfordshire_blue_plaques_board')
    redirect_to(organisation_plaques_path(params[:id])) and return
  end

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(permitted_params)
    if @organisation.save
      flash[:notice] = 'Thanks for adding this organisation.'
      redirect_to organisation_path(@organisation.slug)
    else
      render :new
    end
  end

  def update
    old_slug = @organisation.slug
    if params[:streetview_url] && params[:streetview_url] != ''
      point = help.geolocation_from(params[:streetview_url])
      if !point.latitude.blank? && !point.longitude.blank?
        params[:organisation][:latitude] = point.latitude
        params[:organisation][:longitude] = point.longitude
      end
    end
    if @organisation.update(permitted_params)
      flash[:notice] = 'Updates to organisation saved.'
      redirect_to organisation_path(@organisation.slug)
    else
      @organisation.slug = old_slug
      render :edit
    end
  end

  protected

  def find
    @organisation = Organisation.find_by!(slug: params[:id])
  end

  def find_languages
    @languages = Language.order(name: :desc)
  end

  private

  def help
    Helper.instance
  end

  # access helpers from controller
  class Helper
    include Singleton
    include PlaquesHelper
  end

  def permitted_params
    params.require(:organisation).permit(
      :description,
      :language_id,
      :latitude,
      :longitude,
      :name,
      :notes,
      :slug,
      :streetview_url,
      :website
    )
  end
end
