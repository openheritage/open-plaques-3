module OrganisationsHelper

  def organisation_path(organisation, options = {})
    url_for(options.merge(:controller => :organisations, :action => :show, :id => organisation.slug))
  end

  def edit_organisation_path(organisation, options = {})
    url_for(options.merge(:controller => :organisations, :action => :edit, :id => organisation.slug))
  end

  def organisation_url(organisation, options = {})
    organisation_path(organisation, options.merge!(:only_path => false))
  end
  
end
