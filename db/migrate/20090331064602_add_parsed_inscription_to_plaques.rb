class AddParsedInscriptionToPlaques < ActiveRecord::Migration[4.2]
  def self.up
    add_column :plaques, :parsed_inscription, :text
  end

  def self.down
    remove_column :plaques, :parsed_inscription
  end
end
