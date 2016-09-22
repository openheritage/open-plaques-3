class PersonalRolesController < ApplicationController

  before_filter :authenticate_admin!, only: :destroy
  before_filter :authenticate_user!
  before_filter :find, only: [:destroy, :update, :edit]

  def create
    @personal_role = PersonalRole.new
    @personal_role.role = Role.find(params[:personal_role][:role])
    @personal_role.person = Person.find(params[:personal_role][:person_id])
    if params[:personal_role][:started_at] > ""
      started_at = params[:personal_role][:started_at]
      started_at = started_at + "-01-01" if started_at =~/\d{4}/
      started_at = Date.parse(started_at)
      @personal_role.started_at = started_at
    end
    if params[:personal_role][:ended_at] > ""
      ended_at = params[:personal_role][:ended_at]
      ended_at = ended_at + "-01-01" if ended_at =~/\d{4}/
      ended_at = Date.parse(ended_at)
      @personal_role.ended_at = ended_at
    end
    if @personal_role.save
      flash[:notice] = 'PersonalRole was successfully created.'
      redirect_to(edit_person_path(@personal_role.person))
    else
      @roles = Role.all.order(:name)
      render "people/edit"
    end
  end

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
    if @personal_role.update_attributes(started_at: started_at, ended_at: ended_at, related_person: related_person, ordinal: params[:personal_role][:ordinal])
      if @personal_role.role.name == 'husband' && @personal_role.related_person && !@personal_role.related_person.is_related_to?(@personal_role.person)
        @vice_versa = PersonalRole.new
        @vice_versa.person = @personal_role.related_person
        @vice_versa.role = Role.find_by_name 'wife'
        @vice_versa.related_person = @personal_role.person
        @vice_versa.save
      end
      if @personal_role.role.name == 'wife' && @personal_role.related_person && !@personal_role.related_person.is_related_to?(@personal_role.person)
        @vice_versa = PersonalRole.new
        @vice_versa.person = @personal_role.related_person
        @vice_versa.role = Role.find_by_name 'husband'
        @vice_versa.related_person = @personal_role.person
        @vice_versa.save
      end
      if @personal_role.role.name == 'son' && @personal_role.related_person && !@personal_role.related_person.is_related_to?(@personal_role.person)
        @vice_versa = PersonalRole.new
        @vice_versa.person = @personal_role.related_person
        @vice_versa.role = Role.find_by_name 'father' if @vice_versa.person.male?
        @vice_versa.role = Role.find_by_name 'mother' if @vice_versa.person.female?
        @vice_versa.related_person = @personal_role.person
        @vice_versa.save
      end
      if @personal_role.role.name == 'daughter' && @personal_role.related_person && !@personal_role.related_person.is_related_to?(@personal_role.person)
        @vice_versa = PersonalRole.new
        @vice_versa.person = @personal_role.related_person
        @vice_versa.role = Role.find_by_name 'father' if @vice_versa.person.male?
        @vice_versa.role = Role.find_by_name 'mother' if @vice_versa.person.female?
        @vice_versa.related_person = @personal_role.person
        @vice_versa.save
      end
      if @personal_role.role.name == 'father' && @personal_role.related_person && !@personal_role.related_person.is_related_to?(@personal_role.person)
        @vice_versa = PersonalRole.new
        @vice_versa.person = @personal_role.related_person
        @vice_versa.role = Role.find_by_name 'son' if @vice_versa.person.male?
        @vice_versa.role = Role.find_by_name 'daughter' if @vice_versa.person.female?
        @vice_versa.related_person = @personal_role.person
        @vice_versa.save
      end
      if @personal_role.role.name == 'mother' && @personal_role.related_person && !@personal_role.related_person.is_related_to?(@personal_role.person)
        @vice_versa = PersonalRole.new
        @vice_versa.person = @personal_role.related_person
        @vice_versa.role = Role.find_by_name 'son' if @vice_versa.person.male?
        @vice_versa.role = Role.find_by_name 'daughter' if @vice_versa.person.female?
        @vice_versa.related_person = @personal_role.person
        @vice_versa.save
      end
      if @personal_role.role.name == 'band' && @personal_role.related_person && !@personal_role.related_person.is_related_to?(@personal_role.person)
        @vice_versa = PersonalRole.new
        @vice_versa.person = @personal_role.related_person
        @vice_versa.role = Role.find_by_name 'band member'
        @vice_versa.related_person = @personal_role.person
        @vice_versa.save
      end
      if @personal_role.role.name == 'band member' && @personal_role.related_person && !@personal_role.related_person.is_related_to?(@personal_role.person)
        @vice_versa = PersonalRole.new
        @vice_versa.person = @personal_role.related_person
        @vice_versa.role = Role.find_by_name 'band'
        @vice_versa.related_person = @personal_role.person
        @vice_versa.save
      end
      if @personal_role.role.name == 'footballer' && @personal_role.related_person && !@personal_role.related_person.is_related_to?(@personal_role.person)
        @vice_versa = PersonalRole.new
        @vice_versa.person = @personal_role.related_person
        @vice_versa.role = Role.find_by_name 'association football club'
        @vice_versa.related_person = @personal_role.person
        @vice_versa.save
      end
      if @personal_role.role.name == 'association football club' && @personal_role.related_person && !@personal_role.related_person.is_related_to?(@personal_role.person)
        @vice_versa = PersonalRole.new
        @vice_versa.person = @personal_role.related_person
        @vice_versa.role = Role.find_by_name 'footballer'
        @vice_versa.related_person = @personal_role.person
        @vice_versa.save
      end
      if @personal_role.role.name == 'cricketer' && @personal_role.related_person && !@personal_role.related_person.is_related_to?(@personal_role.person)
        @vice_versa = PersonalRole.new
        @vice_versa.person = @personal_role.related_person
        @vice_versa.role = Role.find_by_name 'cricket club'
        @vice_versa.related_person = @personal_role.person
        @vice_versa.save
      end
      if @personal_role.role.name == 'cricket club' && @personal_role.related_person && !@personal_role.related_person.is_related_to?(@personal_role.person)
        @vice_versa = PersonalRole.new
        @vice_versa.person = @personal_role.related_person
        @vice_versa.role = Role.find_by_name 'cricketer'
        @vice_versa.related_person = @personal_role.person
        @vice_versa.save
      end
      redirect_to(edit_person_path(@personal_role.person))
    else
      render :edit
    end
  end

  def destroy
    @person = @personal_role.person
    @personal_role.destroy
    redirect_to(edit_person_url(@person))
  end

  protected

    def find
      @personal_role = PersonalRole.find(params[:id])
    end

end
