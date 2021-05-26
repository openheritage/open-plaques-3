FactoryBot.define do
  factory :person do
    name { FFaker::Name.name }
    born_on { FFaker::Time.between(200.years.ago, 100.years.ago) }
    died_on { born_on + rand(20*365..100*365).days }
  end
end
