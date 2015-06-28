class PersonalConnectionsController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :find, :only => [:edit, :destroy]
  before_filter :find_plaque, :only => [:edit, :update, :new, :create]
  before_filter :list_people_and_verbs, :only => [:new, :edit]

  def destroy
    @personal_connection.destroy
    redirect_to :back
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
    if @personal_connection.update_attributes(personal_connection_params)
      redirect_to edit_plaque_path(@plaque.id)
    else
      render :edit
    end
  end

  def new
    @personal_connection = @plaque.personal_connections.new
  end

  def create
    @personal_connection = @plaque.personal_connections.new
    @personal_connection.person_id = params[:personal_connection][:person_id]
    @personal_connection.verb_id = params[:personal_connection][:verb_id]

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

    def find
      @personal_connection = PersonalConnection.find(params[:id])
    end

    def find_plaque
      @plaque = Plaque.find(params[:plaque_id])
    end
    
    def list_people_and_verbs
      @verbs = Verb.order(:name).select('id, name')
    end

  private

    def personal_connection_params
      params.require(:personal_connection).permit(
        :person_id,
        :verb_id,
        :started_at,
        :ended_at,
      )
    end

end
