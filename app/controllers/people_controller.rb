class PeopleController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:autocomplete, :index, :show, :update]
  before_filter :find, :only => [:show, :edit, :update, :destroy]

  def index
    redirect_to(:controller => :people_by_index, :action => "show", :id => "a")
  end

  def autocomplete
    limit = params[:limit] ? params[:limit] : 5
    @people = "{}"
    @people = Person.select(:id,:name,:born_on,:died_on)
      .includes(:roles)
      .name_contains(params[:contains])
      .limit(limit) if params[:contains]
    render :json => @people.as_json(
      :only => [:id, :name],
      :methods => [:name_and_dates]
    )
  end

  # GET /people/1
  # GET /people/1.json
  def show
    respond_to do |format|
      format.html
      format.json {
        render :json => @person
      }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  def new
    @person = Person.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @person }
    end
  end

  # GET /people/1/edit
  def edit
    @roles = Role.order(:name)
    @personal_role = PersonalRole.new
    @died_on = @person.died_on.year if @person.died_on
    @born_on = @person.born_on.year if @person.born_on
  end

  # POST /people
  # POST /people.xml
  def create
    @person = Person.new(person_params)
    if params[:born_on].blank?
      @person.born_on = nil
    else
      @person.born_on = Date.parse(params[:born_on] + "-01-01")
    end

    if params[:died_on].blank?
      @person.died_on = nil
    else
      @person.died_on = Date.parse(params[:died_on] + "-01-01")
    end


    respond_to do |format|
      if @person.save
        if params[:role_id] && !params[:role_id].blank?
          @personal_role = PersonalRole.new()
          @personal_role.person_id = @person.id
          @personal_role.role_id = params[:role_id]
          puts @personal_role.person.name + ' ' + @personal_role.role.name
          @personal_role.save!
        end
        flash[:notice] = 'Person was successfully created.'
        format.html { redirect_to(@person) }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
      else
        format.html { render "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    if params[:born_on].blank?
      @person.born_on = nil
    else
      @person.born_on = Date.parse(params[:born_on] + "-01-01")
    end

    if params[:died_on].blank?
      @person.died_on = nil
    else
      @person.died_on = Date.parse(params[:died_on] + "-01-01")
    end

    respond_to do |format|
      if @person.update_attributes(person_params)
        flash[:notice] = 'Person was successfully updated.'
        format.html { redirect_to(@person) }
        format.xml  { head :ok }
      else
        format.html { render "edit" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    @person.destroy
    respond_to do |format|
      format.html { redirect_to(people_url) }
      format.xml  { head :ok }
    end
  end

  protected

    def find
      @person = Person.find(params[:id])
    end

  private

    def person_params
      params.require(:person).permit(
        :name,
        :gender,
        :other_names,
        :aka,
        :surname_starts_with,
        :introduction,
        :wikipedia_url,
        :wikipedia_paras,
        :dbpedia_uri,
        :born_on,
        :died_on)
    end
end
