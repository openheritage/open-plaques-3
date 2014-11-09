class AddCounterCacheToVerb < ActiveRecord::Migration
  def self.up
    add_column :verbs, :personal_connections_count, :integer

    say_with_time("Setting personal_connections_count counter on verbs") do
      Verb.find_each do |verb|
        Verb.update_counters(verb.id, :personal_connections_count => Verb.find(verb.id).personal_connections.size)
      end
    end
  end

  def self.down
    remove_column :verbs, :personal_connections_count
  end
end
