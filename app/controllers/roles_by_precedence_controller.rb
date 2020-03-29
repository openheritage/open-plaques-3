# list roles by precedence
class RolesByPrecedenceController < ApplicationController
  def index
    @roles = Role.where('priority > ?', 0).order(priority: :desc)
    respond_to do |format|
      format.html { render 'roles/by_precedence/index' }
      format.json { render json: @roles }
    end
  end
end
