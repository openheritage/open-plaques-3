class RolesController < ApplicationController

  before_action :authenticate_admin!, only: :destroy
  before_action :authenticate_user!, except: [:index, :show]
  before_action :find, only: [:edit, :update]

  def index
    respond_to do |format|
      format.html { redirect_to(roles_by_index_path('a')) }
      format.json {
        @roles = Role.all.order("personal_roles_count DESC nulls last")
        render json: @roles
      }
    end
  end

  def autocomplete
    limit = params[:limit] ? params[:limit] : 5
    @roles = "{}"
    @roles = Role.select(:id,:name)
      .name_contains(params[:contains])
      .limit(limit) if params[:contains]
    @roles = Role.select(:id,:name)
      .name_starts_with(params[:starts_with])
      .limit(limit) if params[:starts_with]
    render json: @roles.as_json(
      only: [:id, :name]
    )
  end

  def show
    @role = Role.find_by_slug(params[:id])
    @role = Role.new(name: params[:id]) if !@role #dummy role
    @personal_roles = @role.personal_roles
      .paginate(page: params[:page], per_page: 20)
    @pluralized_role = @role.pluralize
    respond_to do |format|
      format.html
      format.json { render json: @role }
    end
  end

  def new
    @role = Role.new
  end

  def create
    @role = Role.new(role_params)
    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to(role_path(@role.slug)) }
      else
        format.html { render "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @role.update_attributes(role_params)
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to(role_path(@role.slug)) }
      else
        format.html { render "edit" }
      end
    end
  end

  protected

    def find
      @role = Role.find_by_slug!(params[:id])
    end

  private

    def role_params
      params.require(:role).permit(
        :abbreviation,
        :commit,
        :description,
        :id,
        :name,
        :prefix,
        :priority,
        :role_type,
        :suffix,
        :slug,
        :wikidata_id)
    end
end
