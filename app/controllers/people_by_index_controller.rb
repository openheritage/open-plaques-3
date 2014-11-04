class PeopleByIndexController < ApplicationController

  def show
    @index = params[:id]
    if @index =~ /^[A-Z]$/
      redirect_to people_by_index_path(@index.downcase), :status => :moved_permanently
    elsif @index =~ /^[a-z]$/
      @people = Person.find(:all, :conditions => {:surname_starts_with => @index, :personal_connections_count => 1..999999})  # Can't figure out how to do a NOT "0" expression.
      @people.sort! { |a,b| a.surname.downcase <=> b.surname.downcase }
      respond_to do |format|
        format.html
        format.kml {
          @parent = @people
          render "plaques/index"
        }
        format.xml
        format.json { render :json => @people }
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end

end
