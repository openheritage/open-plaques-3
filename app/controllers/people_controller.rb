class PeopleController < ApplicationController

  before_filter :authenticate_admin!, only: :destroy
  before_filter :authenticate_user!, except: [:autocomplete, :index, :show, :update]
  before_filter :find, only: [:edit, :update, :destroy]

  def index
    respond_to do |format|
      format.csv {
        @people = Person.all
        send_data(
          "\uFEFF#{PersonCsv.new(@people).build}",
          type: 'text/csv',
          filename: "open-plaques-subjects-all-#{Date.today.to_s}.csv",
          disposition: 'attachment'
        ) and return
      }
    end
    if (params[:filter] && params[:filter]!='')
      begin
        @people = Person.send(params[:filter].to_s).paginate(page: params[:page], per_page: 50)
        @display = params[:filter].to_s
      rescue # an unrecognised filter method
        redirect_to(controller: :people_by_index, action: "show", id: "a")
      end
    else
      redirect_to(controller: :people_by_index, action: "show", id: "a")
    end
  end

  def autocomplete
    limit = params[:limit] ? params[:limit] : 5
    @people = "{}"
    @people = Person.select(:id,:name,:born_on,:died_on)
      .includes(:roles)
      .name_contains(params[:contains])
      .limit(limit) if params[:contains]
    render json: @people.as_json(
      only: [:id, :name],
      methods: [:name_and_dates]
    )
  end

  def show
    if params[:id] =~ /\A\d+\Z/
      @person = Person.find(params[:id])
    else
      redirect_to(controller: :people, action: "index", filter: params[:id]) and return
    end
    respond_to do |format|
      format.html
      format.json { render json: @person }
      format.geojson { render geojson: @person }
      format.csv {
        @people = []
        @people << @person
        send_data(
          "\uFEFF#{PersonCsv.new(@people).build}",
          type: 'text/csv',
          filename: 'open-plaque-subject-' + @person.id.to_s + '.csv',
          disposition: 'attachment'
        )
      }
    end
  end

  def new
    @person = Person.new
    respond_to do |format|
      format.html
      format.xml  { render xml: @person }
    end
  end

  def edit
    @roles = Role.order(:name)
    @personal_role = PersonalRole.new
  end

  def create
    params[:person][:born_on] += "-01-01" if params[:person][:born_on] =~/\d{4}/
    params[:person][:died_on] += "-01-01" if params[:person][:died_on] =~/\d{4}/
    @person = Person.new(person_params)
    respond_to do |format|
      if @person.save
        if params[:role_id] && !params[:role_id].blank?
          @personal_role = PersonalRole.new()
          @personal_role.person_id = @person.id
          @personal_role.role_id = params[:role_id]
          @personal_role.save!
        end
        flash[:notice] = 'Person was successfully created.'
        format.html { redirect_to(@person) }
        format.xml  { render xml: @person, status: :created, location: @person }
      else
        format.html { render "new" }
        format.xml  { render xml: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    params[:person][:born_on] += "-01-01" if params[:person][:born_on] =~/\d{4}/
    params[:person][:died_on] += "-01-01" if params[:person][:died_on] =~/\d{4}/
    respond_to do |format|
      if @person.update_attributes(person_params)
        flash[:notice] = 'Person was successfully updated.'
        format.html { redirect_to(@person) }
        format.xml  { head :ok }
      else
        format.html { render "edit" }
        format.xml  { render xml: @person.errors, status: :unprocessable_entity }
      end
    end
  end

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
        :aka,
        :surname_starts_with,
        :introduction,
        :wikipedia_url,
        :wikipedia_paras,
        :dbpedia_uri,
        :born_on,
        :died_on,
        :find_a_grave_id,
        :ancestry_id)
    end
end
