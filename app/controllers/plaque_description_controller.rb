class PlaqueDescriptionController < PlaqueDetailsController

  before_filter :authenticate_user!

  def edit
    render "plaques/description/edit"
  end

end
