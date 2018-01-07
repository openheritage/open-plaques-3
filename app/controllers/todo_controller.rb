include ActionView::Helpers::TextHelper

class TodoController < ApplicationController

  before_action :authenticate_user!, except: [:index]

  def index
    @unassigned_photo_count = Photo.unassigned.geolocated.count
    @unassigned_ungeolocated_photo_count = Photo.unassigned.ungeolocated.count
    @photographed_not_coloured_plaques_count = Plaque.photographed_not_coloured.count
    @geo_no_location_plaques_count = Plaque.geo_no_location.count
    @plaques_to_add_count = TodoItem.to_add.count
    @lists_to_datacapture = TodoItem.to_datacapture.count
#   @detailed_address_no_geo_count = Plaque.detailed_address_no_geo.count
    uk = Country.find_by_name("United Kingdom")
    @uk_plaques_count = uk.plaques.count
    @no_connection_count = uk.plaques.unconnected.count
    @no_connection_percentage = (@no_connection_count.to_f / @uk_plaques_count.to_f * 100).to_i
    @partial_inscription_count = Plaque.partial_inscription.count
    @partial_inscription_photo_count = Plaque.partial_inscription_photo.count
    @no_roles_count = Person.unroled.count
    @needs_geolocating_count = Plaque.ungeolocated.count
    @no_description_count = Plaque.no_description.count
  end

  def destroy
    @todoitem = TodoItem.find(params[:id])
    @direct_to = 'plaques_to_add'
    @direct_to = 'lists_to_datacapture' if @todoitem.to_datacapture?
    @todoitem.destroy
    redirect_to todo_path(@direct_to)
  end

  def show

    case params[:id]

      when 'colours_from_photos'
        @plaques = Plaque.photographed_not_coloured.paginate(page: params[:page], per_page: 100)
        render :colours_from_photos

      when 'locations_from_geolocations'
        @plaques = Plaque.geo_no_location.paginate(page: params[:page], per_page: 100)
        render :locations_from_geolocations

      when 'plaques_to_add'
        @plaques_to_add = TodoItem.to_add
        render :plaques_to_add

      when 'lists_to_datacapture'
        @lists_to_datacapture = TodoItem.to_datacapture
        render :lists_to_datacapture

      when 'no_connection'
        uk = Country.find_by_name("United Kingdom")
        @uk_plaques_count = uk.plaques.count
        @no_connection_count = uk.plaques.unconnected.count
        @no_connection_percentage = (@no_connection_count.to_f / @uk_plaques_count.to_f * 100).to_i
        @plaques = uk.plaques.unconnected.paginate(page: params[:page], per_page: 100)
        render :no_connection

      when 'partial_inscription'
        @plaques = Plaque.partial_inscription.paginate(page: params[:page], per_page: 100)
        render :partial_inscription

      when 'partial_inscription_photo'
        @plaques = Plaque.partial_inscription_photo.paginate(page: params[:page], per_page: 100)
        render :partial_inscription_photo

      when 'detailed_address_no_geo'
        @plaques = Plaque.detailed_address_no_geo.paginate(page: params[:page], per_page: 100)
        render :detailed_address_no_geo

      when 'fetch_from_flickr'
        flash[:notice] = pluralize(fetch_todo_items, 'photo') + ' added to the list.'
        redirect_to "/todo/plaques_to_add"

      when 'no_roles'
        @people = Person.unroled.paginate(page: params[:page], per_page: 100)
        render :no_roles

      when 'needs_geolocating'
        @plaques = Plaque.ungeolocated.paginate(page: params[:page], per_page: 100)
        render :detailed_address_no_geo

      when 'needs_description'
        @plaques = Plaque.no_description.paginate(page: params[:page], per_page: 100)
        render :needs_description

      when 'unassigned_photo'
        @photos = Photo.unassigned.geolocated.order(:distance_to_nearest_plaque).paginate(page: params[:page], per_page: 100)
        render :unassigned_photo

      when 'unassigned_ungeolocated_photo'
        @photos = Photo.unassigned.ungeolocated.order(:updated_at).paginate(page: params[:page], per_page: 100)
        render :unassigned_photo

      when 'microtask'
        case 5 # rand(7)
          when 0
            puts 'photographed_not_coloured'
            @plaques = Plaque.photographed_not_coloured
            @plaque = @plaques[rand @plaques.length]
            if (@plaque)
              @colours = Colour.order(:name)
              render 'plaque_colour/edit' and return
            end
          when 1
            puts 'partial_inscription_photo'
            @plaques = Plaque.partial_inscription_photo
            @plaque = @plaques[rand @plaques.length]
            if (@plaque)
              @languages = Language.all.order(:name)
              render 'plaque_inscription/edit' and return
            end
          when 2
            puts 'no_role'
            @people = Person.unroled
            @person = @people[rand @people.length]
            if (@person)
              @roles = Role.all.order(:name)
              @personal_role = PersonalRole.new
              @died_on = @person.died_on.year if @person.died_on
              @born_on = @person.born_on.year if @person.born_on
              render 'people/personal_roles/edit' and return
            end
          when 3
            puts 'ungeolocated'
            @plaques = Plaque.ungeolocated
            @plaque = @plaques[rand @plaques.length]
            @geocodes = Array.new
            if (@plaque)
              render 'plaque_geolocation/streetview_edit' and return
            end
          when 4
            puts 'no_dates'
            @people = Person.no_dates
            @person = @people[rand @people.length]
            @personal_role = PersonalRole.new
            @died_on = @person.died_on.year if @person.died_on
            @born_on = @person.born_on.year if @person.born_on
            if (@person)
              @roles = Role.all.order(:name)
              render 'people/dates/edit' and return
            end
          when 5
            puts 'unassigned photo'
            @photos = Photo.unassigned
            @photo = @photos[rand @photos.length]
            if (@photo)
              #    if @photo.unnassigned?
                    @plaques = [Plaque.find(100)]
              #    end
              @licences = Licence.all.order(:name)
              render 'photos/plaque/edit' and return
            end
          when 6
            puts 'no English version'
            @plaques = Plaque.no_english_version
            @plaque = @plaques[rand @plaques.length]
            if (@plaque)
              render 'plaque_inscription/edit' and return
            end

        end
        redirect_to todo_path and return

      else
        puts 'what to do?'
    end

  end

  def new
    @todo = TodoItem.new
    @todo.action = "datacapture"
  end

  def create
    @todo = TodoItem.new(todo_params)

    if @todo.save
      redirect_to todo_path('lists_to_datacapture')
    else
      render :new
    end
  end

  private

    def todo_params
      params.require(:todo).permit(
        :action,
        :description,
        :url,
      )
    end
end
