class ChangePlaqueInscriptionFromScringToText < ActiveRecord::Migration[4.2]
  def self.up
    change_column :plaques, :inscription, :text
  end

  def self.down
    change_column :plaques, :inscription, :string
  end
end
