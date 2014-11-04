class PeopleController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show, :update]

  before_filter :find_person, :only => [:edit, :update, :destroy]

  def index
    redirect_to(:controller => :people_by_index, :action => "show", :id => "a")
  end

  # GET /people/1
  # GET /people/1.kml
  # GET /people/1.osm
  # GET /people/1.xml
  # GET /people/1.json
  def show
    @person = Person.find(params[:id], :include => {:personal_roles => :role})
    respond_to do |format|
      format.html
      format.kml { @plaques = @person.plaques
	  render "plaques/index" }
      format.osm { @plaques = @person.plaques
	  render "plaques/index" }
      format.xml
      format.json {
        if request.env["HTTP_USER_AGENT"].include? "bot"
          puts "** rejecting a bot call to json by "+env["HTTP_USER_AGENT"]
          render :json => {:error => "no-bots"}.to_json, :status => 406
        else
          render :json => @person
        end
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
    @roles = Role.all(:order => :name)
    @personal_role = PersonalRole.new
    @died_on = @person.died_on.year if @person.died_on
    @born_on = @person.born_on.year if @person.born_on
  end

  # POST /people
  # POST /people.xml
  def create
    @person = Person.new(params[:person])
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
      if @person.update_attributes(params[:person])
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

    def find_person
      @person = Person.find(params[:id])
    end

end
