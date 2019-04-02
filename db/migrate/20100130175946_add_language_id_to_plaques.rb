class AddLanguageIdToPlaques < ActiveRecord::Migration[4.2]
  def self.up
    add_column :plaques, :language_id, :integer
  end

  def self.down
    remove_column :plaques, :language_id
  end
end
