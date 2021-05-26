FactoryBot.define do
  factory :country do
    name { FFaker::Address.country }
    alpha2 { FFaker::Address.country_code }
  end
end
