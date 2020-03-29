# edit and update plaque details
class PlaqueDetailsController < ApplicationController
  before_action :find, only: %i[edit show]

  protected

  def find
    @plaque = Plaque.find(params[:plaque_id])
  end
end
