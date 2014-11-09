class AddInscriptionIsStubToPlaques < ActiveRecord::Migration
  def self.up
    add_column :plaques, :inscription_is_stub, :boolean, :default => false
  end

  def self.down
    remove_column :plaques, :inscription_is_stub
  end
end
