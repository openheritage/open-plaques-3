class PlaqueLanguageController < PlaqueDetailsController

  def edit
    @languages = Language.all(:order => :name)
    render "plaques/language/edit"
  end

end
