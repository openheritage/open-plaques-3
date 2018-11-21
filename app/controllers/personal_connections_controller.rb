require 'aws-sdk-comprehend'

class PersonalConnectionsController < ApplicationController

  before_action :authenticate_admin!, only: :destroy
  before_action :find, only: [:destroy]
  before_action :find_plaque, only: [:new, :create]
  before_action :list_people_and_verbs, only: [:new]
  layout 'plaque_edit', only: :new

  def destroy
    @personal_connection.destroy
    redirect_back(fallback_location: root_path)
  end

  def new
    @personal_connection = @plaque.personal_connections.new
    @suggested_people = []
    @entities = []
    begin
      client = Aws::Comprehend::Client.new(region: 'eu-west-1')
      @entities = client.detect_entities({
        text: @plaque.inscription_preferably_in_english,
        language_code: :en,
      })
      @entities = @entities['entities']
      @entities.each_with_index {|ent, i|
        if ent.type == 'PERSON'
          term = ent.text
          term += " (#{@entities[i+1].text}" if @entities[i+1]&.type == 'DATE'
          term += "-#{@entities[i+2].text})" if @entities[i+2]&.type == 'DATE'
          search_result = Person.search(term)
          @suggested_people += search_result if search_result
        end
      }
    rescue
    end
    puts "@suggested_people #{@suggested_people}"
  end

  def create
    if params[:personal_connection][:started_at] =~/\d{4}/
      params[:personal_connection][:started_at] += '-01-01 00:00:01'
    end
    if params[:personal_connection][:ended_at] =~/\d{4}/
      params[:personal_connection][:ended_at] += '-01-01 00:00:01'
    end
    @personal_connection = @plaque.personal_connections.new
    @personal_connection.started_at = params[:personal_connection][:started_at]
    @personal_connection.ended_at = params[:personal_connection][:ended_at]
    @personal_connection.person_id = params[:personal_connection][:person_id]
    @personal_connection.verb_id = params[:personal_connection][:verb_id]
    if @personal_connection.save
      redirect_back(fallback_location: root_path)
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
