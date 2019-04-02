class AddDescriptionToOrganisations < ActiveRecord::Migration[4.2]
  def self.up
    add_column :organisations, :description, :text
  end

  def self.down
    remove_column :organisations, :description
  end
end
