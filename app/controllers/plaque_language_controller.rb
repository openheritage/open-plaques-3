class PlaqueLanguageController < PlaqueDetailsController

  layout 'plaque_edit', only: :edit

  def edit
    @languages = Language.order(name: :desc)
    render "plaques/language/edit"
  end

end
