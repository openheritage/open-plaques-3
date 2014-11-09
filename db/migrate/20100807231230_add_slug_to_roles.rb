class AddSlugToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :slug, :string

    say_with_time("Assigning slugs to roles") do
      Role.find_each do |role|
        role.slug = role.name.downcase.gsub(" ", "_").gsub("'", "").gsub("-", "")
        role.save
      end
    end
  end

  def self.down
    remove_column :roles, :slug
  end
end
