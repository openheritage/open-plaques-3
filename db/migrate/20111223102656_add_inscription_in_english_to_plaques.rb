class AddInscriptionInEnglishToPlaques < ActiveRecord::Migration
  def change
    add_column :plaques, :inscription_in_english, :text
  end
end
