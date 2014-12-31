class RolesByIndexController < ApplicationController

  def show
    @index = params[:id]
    unless @index =~ /[a-z]/
      raise ActiveRecord::RecordNotFound and return
    end
    @roles = Role.where(index: @index).by_popularity
    respond_to do |format|
      format.html
      format.json { render :json => @roles }
    end
  end

end
