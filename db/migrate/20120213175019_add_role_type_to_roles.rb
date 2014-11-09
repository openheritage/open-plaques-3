class AddRoleTypeToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :role_type, :string
    
    ["cat","dog","bulldog","mouse"].each do |a_slug|
      puts a_slug
      r = Role.find_by_slug(a_slug)
      if r
        r.role_type = "animal"
        r.save
      end
    end
    
    ["battle","bomb","bombing","china","conspiracy","movie","printing_press"].each do |a_slug|
      puts a_slug
      r = Role.find_by_slug(a_slug)
      if r
        r.role_type = "thing"
        r.save
      end
    end
    
    ["band","charity","company","diplomatic_mission","football_club","football_league","government_organisation","mod_band","organisation","rugby_football_league","society"].each do |a_slug|
      puts a_slug
      r = Role.find_by_slug(a_slug)
      if r
        r.role_type = "group"
        r.save
      end
    end
    
    ["aerodrome","almshouse","arch","art_gallery","asylum","barracks","brightons_smallest_pub","canal","cathedral","church","cinema","convention_centre","convent","coffee_house","court","courthouse","design_studio","fire_station","film_studio","football_ground","gallows","gallery","gate","grammar_school","hospital","hotel","house","houses","infant_school","institute","laboratory","lead_fresh_water_channel","mill","museum","palace","passage","pharmacy","pier","public_house","print_works","road","school","shop","society","stables","station","street","theatre","town_hall","type_foundry","university","well"].each do |a_slug|
      puts a_slug
      r = Role.find_by_slug(a_slug)
      if r
        r.role_type = "place"
        r.save
      end
    end
    
    ["wife","husband","mother","father","stepmother","stepfather","son","daughter","stepson","stepdaughter","brother","sister","stepbrother","stepsister","aunt","uncle","nephew","niece","grandmother","grandfather","grandson","granddaughter","business_partner"].each do |a_slug|
      puts a_slug
      r = Role.find_by_slug(a_slug)
      if r
        r.role_type = "relationship"
        r.save
      end
    end
    
  end
end
