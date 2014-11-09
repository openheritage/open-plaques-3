class ChangePlaqueInscriptionFromScringToText < ActiveRecord::Migration
  def self.up
    change_column :plaques, :inscription, :text
  end

  def self.down
    change_column :plaques, :inscription, :string
  end
end
