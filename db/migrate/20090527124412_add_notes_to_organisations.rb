class AddNotesToOrganisations < ActiveRecord::Migration
  def self.up
    add_column :organisations, :notes, :text
  end

  def self.down
    remove_column :organisations, :notes
  end
end
