module OrganisationsHelper

  def organisation_path(organisation, options = {})
    url_for(options.merge(controller: :organisations, action: :show, id: organisation.slug))
  end

  def edit_organisation_path(organisation, options = {})
    url_for(options.merge(controller: :organisations, action: :edit, id: organisation.slug))
  end

  def organisation_url(organisation, options = {})
    organisation_path(organisation, options.merge!(only_path: false))
  end

  def organisation_unphotographed_path(organisation, options = {})
    url_for(options.merge(controller: :organisation_plaques, action: :show, organisation_id: organisation.slug, filter: :unphotographed))
  end

  def organisation_ungeolocated_path(organisation, options = {})
    url_for(options.merge(controller: :organisation_plaques, action: :show, organisation_id: organisation.slug, filter: :ungeolocated))
  end

  def organisation_unconnected_path(organisation, options = {})
    url_for(options.merge(controller: :organisation_plaques, action: :show, organisation_id: organisation.slug, filter: :unconnected))
  end
end
