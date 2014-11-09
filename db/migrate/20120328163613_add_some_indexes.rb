class AddSomeIndexes < ActiveRecord::Migration
  def up
    add_index(:areas, :country_id)

    add_index(:people, [:born_on,:died_on], :name => 'born_and_died')

    add_index(:personal_connections, :person_id)
    add_index(:personal_connections, :verb_id)
    add_index(:personal_connections, :location_id)
    add_index(:personal_connections, :plaque_id)

	add_index(:personal_roles, :person_id)
	add_index(:personal_roles, :role_id)
	add_index(:personal_roles, :related_person_id)

	add_index(:photos, :photographer)
	add_index(:photos, :plaque_id)
	add_index(:photos, :licence_id)

	add_index(:roles, :slug)
    add_index(:roles, :index, :name => 'starts_with')
    add_index(:roles, :role_type)

	add_index(:sponsorships, :organisation_id)
	add_index(:sponsorships, :plaque_id)

    add_index(:plaques, :organisation_id)
    add_index(:plaques, :colour_id)
    add_index(:plaques, :location_id)
    add_index(:plaques, [:latitude,:longitude], :name => 'geo')
  end

  def down
    remove_index(:areas, :column => :country_id)

    remove_index(:people, :name => 'born_and_died')

    remove_index(:personal_connections, :column => :person_id)
    remove_index(:personal_connections, :column => :verb_id)
    remove_index(:personal_connections, :column => :location_id)
    remove_index(:personal_connections, :column => :plaque_id)

	remove_index(:personal_roles, :column => :person_id)
	remove_index(:personal_roles, :column => :role_id)
	remove_index(:personal_roles, :column => :related_person_id)

	remove_index(:photos, :column => :photographer)
	remove_index(:photos, :column => :plaque_id)
	remove_index(:photos, :column => :licence_id)

    remove_index(:roles, :column => :slug)
    remove_index(:roles, :name => 'starts_with')
    remove_index(:roles, :column => :role_type)

	remove_index(:sponsorships, :column => :organisation_id)
	remove_index(:sponsorships, :column => :plaque_id)

    remove_index(:plaques, :column => :organisation_id)
    remove_index(:plaques, :column => :colour_id)
    remove_index(:plaques, :column => :location_id)
    remove_index(:plaques, :name => 'geo')
  end
end
