class AddSlugToOrganisations < ActiveRecord::Migration
  def self.up
    add_column :organisations, :slug, :string

    say_with_time("Assigning slugs to organisations") do
      Organisation.find_each do |organisation|
        organisation.update_attributes(:slug => organisation.name.gsub!(" ", "_"))
      end
    end
  end

  def self.down
    remove_column :organisations, :slug
  end
end
