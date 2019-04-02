class AddInscriptionIsStubToPlaques < ActiveRecord::Migration[4.2]
  def self.up
    add_column :plaques, :inscription_is_stub, :boolean, default: false
  end

  def self.down
    remove_column :plaques, :inscription_is_stub
  end
end
