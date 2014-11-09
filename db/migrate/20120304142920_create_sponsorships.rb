class CreateSponsorships < ActiveRecord::Migration
  def change
    create_table :sponsorships do |t|
      t.references :organisation
      t.references :plaque
      t.timestamps
    end
    Plaque.find(:all, :conditions => ['organisation_id is not null']).each do |p|
      s = Sponsorship.new
      s.plaque = p
      s.organisation_id = p.organisation_id
      s.save
    end
  end
end
