# list, show, edit roles
class RolesController < ApplicationController
  before_action :authenticate_admin!, only: :destroy
  before_action :authenticate_user!, except: %i[index show]
  before_action :find, only: %i[edit update]

  def index
    respond_to do |format|
      format.html { redirect_to(roles_by_index_path('a')) }
      format.json do
        @roles = Role.all.order('personal_roles_count DESC nulls last')
        render json: @roles
      end
    end
  end

  def autocomplete
    limit = params[:limit] || 5
    @roles = '{}'
    # show an exact match first
    @roles = Role.select(:id, :name)
                 .name_is(params[:contains] || params[:starts_with])
                 .limit(limit)
    @roles += Role.select(:id, :name)
                  .name_starts_with(params[:contains] || params[:starts_with])
                  .alphabetically
                  .limit(limit)
    if params[:contains]
      @roles += Role.select(:id, :name)
                    .name_contains(params[:contains])
                    .alphabetically
                    .limit(limit)
    end
    @roles.uniq!
    render json: @roles.as_json(
      only: %i[id name]
    )
  end

  def show
    @role = Role.find_by_slug(params[:id])
    @role ||= Role.new(name: params[:id]) # dummy role
    if @role.name.starts_with?('monarch')
      @monarchs = Role.where(slug: [@role.name.gsub('monarch', 'king'), @role.name.gsub('monarch', 'queen')])
      @personal_roles = @role.personal_roles
      @monarchs.each { |m| @personal_roles << m.personal_roles }
      @personal_roles = @personal_roles.sort { |a, b| a.started_at.to_s <=> b.started_at.to_s }
    else
      @personal_roles = @role
                        .personal_roles
                        .by_date
                        .paginate(page: params[:page], per_page: 20)
    end
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
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @role.update(role_params)
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to(role_path(@role.slug)) }
      else
        format.html { render :edit }
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
      :wikidata_id
    )
  end
end
