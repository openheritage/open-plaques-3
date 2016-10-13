class AddLanguageToOrganisations < ActiveRecord::Migration
  def self.up
    add_column :organisations, :language_id, :integer
  end

  def self.down
    remove_column :organisations, :language_id
  end
end
