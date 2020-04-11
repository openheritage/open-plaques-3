FactoryBot.define do
  factory :plaque do
    inscription { "#{FFaker::Name.name} (#{born = FFaker::Time.between(200.years.ago, 100.years.ago).year}-#{born + rand(20..100)}) #{['lived', 'was born', 'died'].sample} here" }
    address { FFaker::AddressUK.street_address }
  end
end
