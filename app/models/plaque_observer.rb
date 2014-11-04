class PlaqueObserver < ActiveRecord::Observer
  def after_create(plaque)
    PlaqueMailer.deliver_new_plaque_email(plaque)
  end
end