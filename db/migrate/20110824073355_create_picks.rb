class CreatePicks < ActiveRecord::Migration
  def self.up
    create_table :picks do |t|
      t.integer :plaque_id
      t.string :description
      t.datetime :feature_on
      t.datetime :last_featured
      t.integer :featured_count

      t.timestamps
    end
  end

  def self.down
    drop_table :picks
  end
end
