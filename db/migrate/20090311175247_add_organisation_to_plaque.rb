class AddOrganisationToPlaque < ActiveRecord::Migration[4.2]
  def self.up
    add_column :plaques, :organisation_id, :integer
  end

  def self.down
    remove_column :plaques, :organisation_id
  end
end
