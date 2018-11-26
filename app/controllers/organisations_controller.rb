class OrganisationsController < ApplicationController

  before_action :authenticate_admin!, only: :destroy
  before_action :authenticate_user!, except: [:autocomplete, :index, :show]
  before_action :find, only: [:edit, :update]
  before_action :find_languages, only: [:edit, :create]

  def index
    @organisation_count = Organisation.all.count
    @organisations = Organisation.all
      .select(:language_id, :name, :slug, :sponsorships_count)
      .in_alphabetical_order
      .paginate(page: params[:page], per_page: 50)
    @top_10 = Organisation.all
      .select(:name, :slug, :sponsorships_count)
      .in_count_order
      .limit(10)
    respond_to do |format|
      format.html
      format.json { render json: @organisations }
      format.geojson {
        @organisations = Organisation.all.in_alphabetical_order
        render geojson: @organisations
      }
    end
  end

  def autocomplete
    limit = params[:limit] ? params[:limit] : 5
    if params[:contains]
      @organisations = Organisation.select(:id, :name).name_contains(params[:contains]).limit(limit)
    elsif params[:starts_with]
      @organisations = Organisation.select(:id, :name).name_starts_with(params[:starts_with]).limit(limit)
    else
      @organisations = "{}"
    end
    render json: @organisations.as_json(only: [:id, :name])
  end

  def show
    params[:id] = "oxfordshire_blue_plaques_board" if (params[:id]=="oxfordshire_blue_plaques_scheme")
    redirect_to(organisation_plaques_path(params[:id])) and return
  end

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(organisation_params)
    if @organisation.save
      redirect_to organisation_path(@organisation.slug)
    else
      render :new
    end
  end

  def update
    old_slug = @organisation.slug
    if (params[:streetview_url] && params[:streetview_url]!='')
      point = help.geolocation_from params[:streetview_url]
      if !point.latitude.blank? && !point.longitude.blank?
        params[:organisation][:latitude] = point.latitude
        params[:organisation][:longitude] = point.longitude
      end
    end
    if @organisation.update_attributes(organisation_params)
      flash[:notice] = 'Updates to organisation saved.'
      redirect_to organisation_path(@organisation.slug)
    else
      @organisation.slug = old_slug
      render :edit
    end
  end

  protected

    def find
      @organisation = Organisation.find_by_slug!(params[:id])
    end

    def find_languages
      @languages = Language.order(name: :desc)
    end

  private

    def help
      Helper.instance
    end

    class Helper
      include Singleton
      include PlaquesHelper
    end

    def organisation_params
      params.require(:organisation).permit(
        :description,
        :language_id,
        :latitude,
        :longitude,
        :name,
        :notes,
        :slug,
        :streetview_url,
        :website,
      )
    end
end
