class AddOrganisationToPlaque < ActiveRecord::Migration
  def self.up
    add_column :plaques, :organisation_id, :integer
  end

  def self.down
    remove_column :plaques, :organisation_id
  end
end
