# control personal roles
class PersonalRolesController < ApplicationController
  before_action :authenticate_admin!, only: :destroy
  before_action :authenticate_user!
  before_action :find, only: %i[destroy update edit]

  def create
    @personal_role = PersonalRole.new
    @personal_role.role = Role.find(params[:personal_role][:role])
    @personal_role.person = Person.find(params[:personal_role][:person_id])
    if params[:personal_role][:started_at] > ''
      started_at = params[:personal_role][:started_at]
      started_at += '-01-01' if started_at =~ /\d{4}/
      started_at = Date.parse(started_at)
      @personal_role.started_at = started_at
    end
    if params[:personal_role][:ended_at] > ''
      ended_at = params[:personal_role][:ended_at]
      ended_at += '-01-01' if ended_at =~ /\d{4}/
      ended_at = Date.parse(ended_at)
      @personal_role.ended_at = ended_at
    end
    if @personal_role.save
      flash[:notice] = 'PersonalRole was successfully created.'
      redirect_to(edit_person_path(@personal_role.person))
    else
      @roles = Role.all.alphabetically
      render 'people/edit'
    end
  end

  def update
    related_person = nil
    related_person = Person.find(params[:personal_role][:related_person_id]) if params[:personal_role][:related_person_id]
    started_at = nil
    if params[:personal_role][:started_at] > ''
      started_at = params[:personal_role][:started_at]
      started_at += '-01-01' if started_at =~ /\d{4}/
      started_at = Date.parse(started_at)
    end
    ended_at = nil
    if params[:personal_role][:ended_at] > ''
      ended_at = params[:personal_role][:ended_at]
      ended_at += '-01-01' if ended_at =~ /\d{4}/
      ended_at = Date.parse(ended_at)
    end
    if @personal_role.update(
      started_at: started_at,
      ended_at: ended_at,
      related_person: related_person,
      ordinal: params[:personal_role][:ordinal],
      primary: params[:personal_role][:primary]
    )
      opposite = nil
      if @personal_role.related_person # && !@personal_role.related_person.related_to?(@personal_role.person)
        opposite = Role.find_by(name: 'wife') if @personal_role.role.name == 'husband'
        opposite = Role.find_by(name: 'husband') if @personal_role.role.name == 'wife'
        opposite = Role.find_by(name: 'father') if @personal_role.role.role_type == 'child' && @personal_role.related_person.male?
        opposite = Role.find_by(name: 'mother') if @personal_role.role.role_type == 'child' && @personal_role.related_person.female?
        opposite = Role.find_by(name: 'son') if @personal_role.role.role_type == 'parent' && @personal_role.related_person.male?
        opposite = Role.find_by(name: 'daughter') if @personal_role.role.role_type == 'parent' && @personal_role.related_person.female?
        opposite = Role.find_by(name: 'band_member') if @personal_role.role.name == 'band'
        opposite = Role.find_by(name: 'band') if @personal_role.role.name == 'band member'
        opposite = Role.find_by(name: 'band') if @personal_role.role.name == 'lead singer'
        opposite = Role.find_by(name: 'band') if @personal_role.role.name == 'drummer'
        opposite = Role.find_by(name: 'footballer') if @personal_role.role.name == 'association football club'
        opposite = Role.find_by(name: 'association football club') if @personal_role.role.name == 'footballer'
        opposite = Role.find_by(name: 'football manager') if @personal_role.role.name == 'football managerial post'
        opposite = Role.find_by(name: 'football managerial post') if @personal_role.role.name == 'football manager'
        opposite = Role.find_by(name: 'cricketer') if @personal_role.role.name == 'cricket club'
        opposite = Role.find_by(name: 'cricket club') if @personal_role.role.name == 'cricketer'
        opposite = Role.find_by(name: 'business partner') if @personal_role.role.name == 'business partner'
        opposite = Role.find_by(name: 'friend') if @personal_role.role.name == 'friend'
        opposite = Role.find_by(name: 'creator') if @personal_role.role.name == 'creation'
        opposite = Role.find_by(name: 'creation') if @personal_role.role.name == 'creator'
        opposite = Role.find_by(name: 'founder') if @personal_role.role.name == 'foundation'
        opposite = Role.find_by(name: 'foundation') if @personal_role.role.name == 'founder'
        opposite = Role.find_by(name: 'battle') if @personal_role.role.name == 'battle veteran'
        opposite = Role.find_by(name: 'battle veteran') if @personal_role.role.name == 'battle'
      end
      unless opposite.nil?
        it_exists = false
        if @personal_role.started_at && @personal_role.ended_at
          it_exists = !PersonalRole.find_by(
            person_id: @personal_role.related_person.id,
            related_person: @personal_role.person.id,
            role_id: opposite.id,
            started_at: @personal_role.started_at,
            ended_at: @personal_role.ended_at
          ).nil?
          it_exists ||= !PersonalRole.find_by(
            person_id: @personal_role.related_person.id,
            related_person: @personal_role.person.id,
            role_id: opposite.id,
            started_at: nil,
            ended_at: nil
          ).nil?
        else
          it_exists = !PersonalRole.find_by(
            person_id: @personal_role.related_person.id,
            related_person: @personal_role.person.id,
            role_id: opposite.id
          ).nil?
        end
        unless it_exists
          @vice_versa = PersonalRole.new
          @vice_versa.person = @personal_role.related_person
          @vice_versa.role = opposite
          @vice_versa.related_person = @personal_role.person
          @vice_versa.started_at = @personal_role.started_at if @personal_role.started_at
          @vice_versa.ended_at = @personal_role.ended_at if @personal_role.ended_at
          @vice_versa.save
        end
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
