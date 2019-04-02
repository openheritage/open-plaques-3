class AddInscriptionInEnglishToPlaques < ActiveRecord::Migration[4.2]
  def change
    add_column :plaques, :inscription_in_english, :text
  end
end
