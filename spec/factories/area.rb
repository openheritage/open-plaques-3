FactoryBot.define do
  factory :area do
    country { Country.uk }
    name { FFaker::AddressUK.city }
  end
end
