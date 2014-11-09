class AddSurnameStartsWithToPerson < ActiveRecord::Migration

  class Person < ActiveRecord::Base
  end

  def self.up
    add_column :people, :surname_starts_with, :string
    add_index :people, :surname_starts_with
    add_index :people, :index

    say_with_time("Adding surname indexes to people") do
      Person.find(:all).each do |person|
        person.surname_starts_with = person.name[person.name.rindex(" ") ? person.name.rindex(" ") + 1 : 0,1].downcase
        person.save!
      end
    end
  end

  def self.down
    remove_column :people, :surname_starts_with
    remove_index :people, :index
  end
end
