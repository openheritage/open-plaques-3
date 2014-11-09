class AddSlugToCountries < ActiveRecord::Migration
  def self.up
    add_column :areas, :slug, :string

    say_with_time("Assigning slugs to areas") do
      Area.find_each do |area|
        area.slug = area.name.downcase.gsub!(" ", "_")
        area.save
      end
    end
  end

  def self.down
    remove_column :areas, :slug
  end
end
