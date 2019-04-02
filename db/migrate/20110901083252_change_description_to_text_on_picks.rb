class ChangeDescriptionToTextOnPicks < ActiveRecord::Migration[4.2]
  def self.up
    change_column :picks, :description, :text, limit: nil
  end

  def self.down
    change_column :picks, :description, :string
  end
end