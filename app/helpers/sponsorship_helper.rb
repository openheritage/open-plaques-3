module SponsorshipHelper

  def new_sponsorship_path(plaque)
    url_for(:controller => :sponsorships, :action => :new, :plaque_id => plaque.id)
  end

end
