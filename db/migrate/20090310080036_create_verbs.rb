class CreateVerbs < ActiveRecord::Migration
  def self.up
    create_table :verbs do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :verbs
  end
end
