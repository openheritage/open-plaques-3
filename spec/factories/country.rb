FactoryBot.define do
  factory :country do
    name { FFaker::Name.name }
    alpha2 { 'ab' }
  end
end
