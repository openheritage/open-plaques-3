FactoryBot.define do
  factory :photo do
#    photographer { Faker::Name.name }
    url { "https://www.geograph.org.uk/photo/#{rand(3000)}" }
  end
end
