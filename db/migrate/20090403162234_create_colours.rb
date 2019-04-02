class CreateColours < ActiveRecord::Migration[4.2]
  def self.up
    create_table :colours do |t|
      t.string :name
      t.integer :plaques_count

      t.timestamps
    end
  end

  def self.down
    drop_table :colours
  end
end
