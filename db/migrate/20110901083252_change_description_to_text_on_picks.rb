class ChangeDescriptionToTextOnPicks < ActiveRecord::Migration
  def self.up
    change_column :picks, :description, :text, :limit => nil
  end

  def self.down
    change_column :picks, :description, :string
  end
end