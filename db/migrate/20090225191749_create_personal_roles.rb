class CreatePersonalRoles < ActiveRecord::Migration[4.2]
  def self.up
    create_table :personal_roles do |t|
      t.integer :person_id, :role_id
      t.timestamps
    end
  end

  def self.down
    drop_table :personal_roles
  end
end
