class AddRelatedPersonToPersonalRole < ActiveRecord::Migration
  def change
    add_column :personal_roles, :related_person_id, :integer
  end
end
