class AddIndexToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :index, :string

    say_with_time("Setting index letter on people") do
      Person.find_each do |person|
        person.index = person.name[0,1].downcase
        person.save!
      end
    end
  end

  def self.down
    remove_column :people, :index
  end
end
