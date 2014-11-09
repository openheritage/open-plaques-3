class AddPersonalConnectionsCountToPlaques < ActiveRecord::Migration
  class Plaque < ActiveRecord::Base
  end
  class PersonalConnections < ActiveRecord::Base
  end

  def self.up
    add_column :plaques, :personal_connections_count, :integer, :default => 0
    add_index :plaques, :personal_connections_count

    say_with_time("Setting counter caches for existing plaques") do
      Plaque.find_each do |plaque|
        plaque.update_attribute(:personal_connections_count, PersonalConnection.where(:plaque_id => plaque.id).count)
      end
    end
  end

  def self.down
    remove_column :plaques, :personal_connections_count
  end
end