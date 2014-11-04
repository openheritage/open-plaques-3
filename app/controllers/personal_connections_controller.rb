class PersonalConnectionsController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy

  before_filter :find_plaque, :only => [:edit, :update, :new, :create]
  before_filter :find_personal_connection, :only => [:edit, :destroy]
  before_filter :list_people_and_verbs, :only => [:new, :edit]

  def destroy
    @personal_connection.destroy
    redirect_to :back
  end

  def edit
    @locations = Location.all(:order => :name)
  end

  def update
    @personal_connection = @plaque.personal_connections.find(params[:id])
    if params[:personal_connection][:started_at] > ""
      started_at = params[:personal_connection][:started_at]
      if started_at =~/\d{4}/
        started_at = started_at + "-01-01"
        started_at = Date.parse(started_at)
        @personal_connection.started_at = started_at
      end
    end
    if params[:personal_connection][:ended_at] > ""
      ended_at = params[:personal_connection][:ended_at]
      if ended_at =~/\d{4}/
        ended_at = ended_at + "-01-01"
        ended_at = Date.parse(ended_at)
        @personal_connection.ended_at = ended_at
      end
    end
    if @personal_connection.update_attributes(params[:personal_connection])
      redirect_to edit_plaque_path(@plaque.id)
    else
      render :edit
    end
  end

  def new
    @personal_connection = @plaque.personal_connections.new
  end

  def create
    @personal_connection = @plaque.personal_connections.new(params[:personal_connection])
    if params[:personal_connection][:started_at] > ""
      started_at = params[:personal_connection][:started_at]
      if started_at =~/\d{4}/
        started_at = started_at + "-01-01"
        started_at = Date.parse(started_at)
        @personal_connection.started_at = started_at
      end
    end
    if params[:personal_connection][:ended_at] > ""
      ended_at = params[:personal_connection][:ended_at]
      if ended_at =~/\d{4}/
        ended_at = ended_at + "-01-01"
        ended_at = Date.parse(ended_at)
        @personal_connection.ended_at = ended_at
      end
    end
    if @personal_connection.save
      redirect_to :back
    else
      # can we just redirect to new?
      list_people_and_verbs
      render :new
    end
  end

  protected

    def find_plaque
      @plaque = Plaque.find(params[:plaque_id])
    end

    def find_personal_connection
      @personal_connection = PersonalConnection.find(params[:id])
    end
    
    def list_people_and_verbs
      @people = Person.all(:order => :name, :select => 'id, name, born_on, died_on')
      @verbs = Verb.all(:order => :name, :select => 'id, name' )
      @common_verbs = Verb.common
    end

end
