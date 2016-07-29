class PlaqueLanguageController < PlaqueDetailsController

  def edit
    @languages = Language.all.order(name: :desc)
    render "plaques/language/edit"
  end

end
