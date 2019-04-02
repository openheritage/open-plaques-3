class AddNotesToOrganisations < ActiveRecord::Migration[4.2]
  def self.up
    add_column :organisations, :notes, :text
  end

  def self.down
    remove_column :organisations, :notes
  end
end
