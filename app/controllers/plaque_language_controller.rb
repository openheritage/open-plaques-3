# edit a Plaque language
class PlaqueLanguageController < PlaqueDetailsController
  layout 'plaque_edit', only: :edit

  def edit
    @languages = Language.alphabetically
    render 'plaques/language/edit'
  end
end
