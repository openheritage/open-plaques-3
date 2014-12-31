class RolesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :find, :only => [:show, :edit, :update]

  def index
    respond_to do |format|
      format.html { redirect_to(roles_by_index_path('a')) }
      @roles = Role.by_popularity
      format.json { render :json => @roles }
    end
  end

  # GET /roles/artist
  # GET /roles/artist.xml
  def show
    @related_roles = @role.related_roles
    for person in @role.people
      if person # a role record may exist that no longer has a person joined to it
        if (@plaques == nil)
          @plaques = person.plaques
        else
          @plaques = @plaques + person.plaques
        end
      end
    end
    @zoom = 7
    respond_to do |format|
      format.html
      format.json { render :json => @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(role_params)
    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to(role_path(@role.slug)) }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    respond_to do |format|
    if @role.update_attributes(role_params)
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to(role_path(@role.slug)) }
        format.xml  { head :ok }
      else
        format.html { render "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
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
        :name,
        :abbreviation,
        :slug,
        :wikipedia_stub,
        :role_type,
        :commit,
        :id)
    end
end
