class CreatePlaces < ActiveRecord::Migration[4.2]
  def self.up
    create_table :places do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :places
  end
end
