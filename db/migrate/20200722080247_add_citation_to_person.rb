class AddCitationToPerson < ActiveRecord::Migration[6.0]
  def change
    add_column :people, :citation, :string
  end
end
