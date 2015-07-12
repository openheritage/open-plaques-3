class RemoveOrganisationFromPlaque < ActiveRecord::Migration
  def self.up
    remove_column :plaques, :organisation_id
  end

  def self.down
    add_column :plaques, :organisation_id, :int
  end
end
