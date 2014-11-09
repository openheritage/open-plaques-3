class AddSponsorshipsCountToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :sponsorships_count, :integer, :default => 0
    say_with_time("Setting counter caches for existing organisations") do
      Organisation.find_each do |o|
        Organisation.reset_counters(o.id, :sponsorships)
        o.save
      end
    end
  end
end
