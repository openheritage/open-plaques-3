include ActionView::Helpers::TextHelper

class TodoController < ApplicationController

  def index
    @photographed_not_coloured_plaques_count = Plaque.photographed_not_coloured.count
    @geo_no_location_plaques_count = Plaque.geo_no_location.count
    @location_no_area_plaques_count = Location.no_area.count
    @plaques_to_add_count = TodoItem.to_add.count
    @lists_to_datacapture = TodoItem.to_datacapture.count
#   @detailed_address_no_geo_count = Plaque.detailed_address_no_geo.count
    @no_connection_count = Plaque.no_connection.count
    @partial_inscription_count = Plaque.partial_inscription.count
    @partial_inscription_photo_count = Plaque.partial_inscription_photo.count
    @no_roles_count = Person.no_role.count
    @needs_geolocating_count = Plaque.ungeolocated.count
    @no_description_count = Plaque.no_description.count
    @unassigned_photo_count = Photo.unassigned.count
    @unphotographed_plaque_count = Plaque.unphotographed.count
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
        @plaques = Plaque.photographed_not_coloured.paginate(:page => params[:page], :per_page => 100)
        render :colours_from_photos

      when 'locations_from_geolocations'
        @plaques = Plaque.geo_no_location.paginate(:page => params[:page], :per_page => 100)
        render :locations_from_geolocations

      when 'areas_from_locations'
        @locations = Location.no_area
        render :areas_from_locations

      when 'plaques_to_add'
        @plaques_to_add = TodoItem.to_add
        render :plaques_to_add

      when 'lists_to_datacapture'
        @lists_to_datacapture = TodoItem.to_datacapture
        render :lists_to_datacapture

      when 'no_connection'
        @plaques = Plaque.no_connection.paginate(:page => params[:page], :per_page => 100)
        render :no_connection

      when 'partial_inscription'
        @plaques = Plaque.partial_inscription.paginate(:page => params[:page], :per_page => 100)
        render :partial_inscription

      when 'partial_inscription_photo'
        @plaques = Plaque.partial_inscription_photo.paginate(:page => params[:page], :per_page => 100)
        render :partial_inscription_photo

      when 'detailed_address_no_geo'
        @plaques = Plaque.detailed_address_no_geo.paginate(:page => params[:page], :per_page => 100)
        render :detailed_address_no_geo

      when 'fetch_from_flickr'
        flash[:notice] = pluralize(fetch_todo_items, 'photo') + ' added to the list.'
        redirect_to "/todo/plaques_to_add"

      when 'no_roles'
        @people = Person.no_role.paginate(:page => params[:page], :per_page => 100)
        render :no_roles

      when 'needs_geolocating'
        @plaques = Plaque.ungeolocated.paginate(:page => params[:page], :per_page => 100)
        render :detailed_address_no_geo

      when 'needs_description'
        @plaques = Plaque.no_description.paginate(:page => params[:page], :per_page => 100)
        render :needs_description

      when 'unassigned_photo'
        @photos = Photo.unassigned.paginate(:page => params[:page], :per_page => 100)
        render :unassigned_photo
        
      when 'unphotographed'
          @plaques = Plaque.unphotographed.paginate(:page => params[:page], :per_page => 100)
          render :unphotographed
      
      when 'microtask'
        case 5 # rand(7)
          when 0
            puts 'photographed_not_coloured'
            @plaques = Plaque.photographed_not_coloured
            @plaque = @plaques[rand @plaques.length]
            if (@plaque)
              @colours = Colour.find(:all, :order => :name)
              render 'plaque_colour/edit' and return
            end
          when 1
            puts 'partial_inscription_photo'
            @plaques = Plaque.partial_inscription_photo
            @plaque = @plaques[rand @plaques.length]
            if (@plaque)
              @languages = Language.all(:order => :name)
              render 'plaque_inscription/edit' and return
            end
          when 2
            puts 'no_role'
            @people = Person.no_role
            @person = @people[rand @people.length]
            if (@person)
              @roles = Role.all(:order => :name)
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
              @roles = Role.all(:order => :name)
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
              @licences = Licence.all(:order => :name)
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
    @todo = TodoItem.new(params[:todo])

    if @todo.save
      redirect_to todo_path('lists_to_datacapture')
    else
      render :new
    end
  end

end
