class PlaqueDescriptionController < PlaqueDetailsController

  before_action :authenticate_user!
  layout 'plaque_edit', only: :edit

  def edit
    render "plaques/description/edit"
  end

end
