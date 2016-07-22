class AddFindAGraveAndAncestryIdsToPerson < ActiveRecord::Migration
  def change
    add_column :people, :find_a_grave_id, :string
    add_column :people, :ancestry_id, :string
  end
end
