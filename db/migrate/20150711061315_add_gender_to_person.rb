class AddGenderToPerson < ActiveRecord::Migration
  def change
    add_column :people, :gender, :string, default: 'u'
  end
end
