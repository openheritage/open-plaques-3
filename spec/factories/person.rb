FactoryBot.define do
  factory :person do
    name { FFaker::Name.name }
  end
end
