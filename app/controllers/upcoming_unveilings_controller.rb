class UpcomingUnveilingsController < ApplicationController
 
  def show
    @upcoming_plaques = Plaque.where(erected_at: [Date.today..(Date.today + 1.year)]).order('erected_at')
  end

end
