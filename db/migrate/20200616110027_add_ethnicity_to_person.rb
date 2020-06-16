class AddEthnicityToPerson < ActiveRecord::Migration[6.0]
  def change
    add_column :people, :ethnicity, :string
  end
end
