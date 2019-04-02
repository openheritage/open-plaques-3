class AddRelatedPersonToPersonalRole < ActiveRecord::Migration[4.2]
  def change
    add_column :personal_roles, :related_person_id, :integer
  end
end
