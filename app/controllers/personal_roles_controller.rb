class PersonalRolesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!

  before_filter :find_personal_role, :only => [:destroy, :update, :edit]

  # POST /personal_roles
  # POST /personal_roles.xml
  def create
    @personal_role = PersonalRole.new
    @role = Role.find(params[:personal_role][:role])
    @personal_role.role = @role
    @person = Person.find(params[:personal_role][:person_id])
    @personal_role.person = @person

    # TODO: need better validation on the date format here.
    if params[:personal_role][:started_at] > ""
      started_at = params[:personal_role][:started_at]
      if started_at =~/\d{4}/
        started_at = started_at + "-01-01"
      end
      started_at = Date.parse(started_at)
      @personal_role.started_at = started_at
    end

   if params[:personal_role][:ended_at] > ""
      ended_at = params[:personal_role][:ended_at]
      if ended_at =~/\d{4}/
        ended_at = ended_at + "-01-01"
      end
      ended_at = Date.parse(ended_at)
      @personal_role.ended_at = ended_at
    end

    if @personal_role.save
      flash[:notice] = 'PersonalRole was successfully created.'
      redirect_to(edit_person_path(@personal_role.person))
    else
      @roles = Role.all(:order => :name)

      render "people/edit"
    end

  end

  # PUT /personal_roles/1
  # PUT /personal_roles/1.xml
  def update
    related_person = nil
    if (params[:personal_role][:related_person_id])
      related_person = Person.find(params[:personal_role][:related_person_id])
    end
    started_at = nil
    if (params[:personal_role][:started_at]>"")
      started_at = params[:personal_role][:started_at]
      if started_at =~/\d{4}/
        started_at = Date.parse(started_at + "-01-01")
      else
        started_at = Date.parse(started_at)
      end
    end

    ended_at = nil
    if (params[:personal_role][:ended_at]>"")
      ended_at = params[:personal_role][:ended_at]
      if ended_at =~/\d{4}/
        ended_at = Date.parse(ended_at + "-01-01")
      else
        ended_at = Date.parse(ended_at)
      end
    end

    if @personal_role.update_attributes(:started_at => started_at, :ended_at => ended_at, :related_person => related_person, :ordinal => params[:personal_role][:ordinal])
      redirect_to(edit_person_path(@personal_role.person))
    else
      render :edit
    end

  end

  # DELETE /personal_roles/1
  # DELETE /personal_roles/1.xml
  def destroy
    @person = @personal_role.person
    @personal_role.destroy

    respond_to do |format|
      format.html { redirect_to(edit_person_url(@person)) }
      format.xml  { head :ok }
    end
  end

  def edit
    @people = Person.all(:order => :name)
  end

  protected

    def find_personal_role
      @personal_role = PersonalRole.find(params[:id])
    end

end
