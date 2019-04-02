class CreateSponsorships < ActiveRecord::Migration[4.2]
  def change
    create_table :sponsorships do |t|
      t.references :organisation
      t.references :plaque
      t.timestamps
    end
    Plaque.where('organisation_id is not null').each do |p|
      s = Sponsorship.new
      s.plaque = p
      s.organisation_id = p.organisation_id
      s.save
    end
  end
end
