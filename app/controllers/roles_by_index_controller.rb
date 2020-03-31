# list roles by starting letter
class RolesByIndexController < ApplicationController
  def show
    @index = params[:id][0, 1]
    @roles = Role.where(index: @index).order('personal_roles_count DESC nulls last')
    respond_to do |format|
      format.html { render 'roles/by_index/show' }
      format.json { render json: @roles }
    end
  end
end
