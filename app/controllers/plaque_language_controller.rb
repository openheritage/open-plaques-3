class PlaqueLanguageController < PlaqueDetailsController

  def edit
    @languages = Language.order(name: :desc)
    render "plaques/language/edit"
  end

end
