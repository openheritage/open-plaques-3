class WomenByIndexController < ApplicationController

  def show
    @index = params[:id]
    if @index =~ /^[A-Z]$/
      redirect_to people_by_index_path(@index.downcase), status: :moved_permanently
    elsif @index =~ /^[a-z]$/
      # roles used by person.full_name
      @people = Person
        .where(surname_starts_with: @index)
        .connected
        .female
        .paginate(page: params[:page], per_page: 50)
        .preload(:personal_roles, :roles, :main_photo)
        .to_a.sort! { |a,b| a.surname.downcase <=> b.surname.downcase }
      respond_to do |format|
        format.html { render "people/by_index/show" }
        format.xml
        format.json { render json: @people }
      end
    else
      raise ActiveRecord::RecordNotFound
    end
  end

end
