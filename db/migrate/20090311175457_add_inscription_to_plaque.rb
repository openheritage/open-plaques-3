class AddInscriptionToPlaque < ActiveRecord::Migration[4.2]
  def self.up
    add_column :plaques, :inscription, :string
  end

  def self.down
    remove_column :plaques, :inscription
  end
end
