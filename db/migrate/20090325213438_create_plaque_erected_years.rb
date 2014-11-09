class CreatePlaqueErectedYears < ActiveRecord::Migration
  def self.up
    create_table :plaque_erected_years do |t|
      t.string :name
      t.integer :plaques_count

      t.timestamps
    end
    add_column :plaques, :plaque_erected_year_id, :integer
  end

  def self.down
    remove_column :plaques, :plaque_erected_year_id
    drop_table :plaque_erected_years
  end
end
