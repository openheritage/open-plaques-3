class PersonRolesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :find, :only => [:show]

  def show
    @personal_role = PersonalRole.new
    respond_to do |format|
      format.html { render 'people/personal_roles/show' }
    end
  end

  protected

    def find
      @person = Person.find(params[:person_id], :include => {:personal_roles => :role})
    end

end
