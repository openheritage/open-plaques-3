class AddGenderToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :gender, :string, default: 'u'
  end
end
