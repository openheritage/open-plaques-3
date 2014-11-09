class CreateLicenses < ActiveRecord::Migration
  def self.up
    create_table :licenses do |t|
      t.string :name
      t.string :url
      t.boolean :allows_commercial_use

      t.timestamps
    end
  end

  def self.down
    drop_table :licenses
  end
end
