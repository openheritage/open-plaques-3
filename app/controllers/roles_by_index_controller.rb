class RolesByIndexController < ApplicationController

  def show
    @index = params[:id]
    unless @index =~ /[a-z]/
      raise ActiveRecord::RecordNotFound and return
    end
    @roles = Role.where(index: @index).order("personal_roles_count DESC nulls last")
    respond_to do |format|
      format.html { render "roles/by_index/show" }
      format.json { render json: @roles }
    end
  end

end
