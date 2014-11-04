class RolesByIndexController < ApplicationController

  def show
    @index = params[:id]
    unless @index =~ /[a-z]/
      raise ActiveRecord::RecordNotFound and return
    end
    @roles = Role.find(:all, :conditions => {:index => @index}, :order => "upper(name)")
  end

  def index

  end

end
