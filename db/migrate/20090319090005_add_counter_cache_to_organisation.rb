class AddCounterCacheToOrganisation < ActiveRecord::Migration
  def self.up
    add_column :organisations, :plaques_count, :integer

    say_with_time("Setting plaques_count conter on organisations") do
      Organisation.find_each do |organisation|
        Organisation.update_counters(organisation.id, :plaques_count => Organisation.find(organisation.id).plaques.size)
      end
    end
  end

  def self.down
    remove_column :organisations, :plaques_count
  end
end
