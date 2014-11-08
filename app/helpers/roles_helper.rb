module RolesHelper

  def role_path(role, options = {})
    url_for(options.merge(:controller => :roles, :action => :show, :id => role.slug))
  end

  def edit_role_path(role, options = {})
    url_for(options.merge(:controller => :roles, :action => :edit, :id => role.slug))
  end

  def role_url(role, options = {})
    role_path(role, options.merge!(:only_path => false))
  end

end
