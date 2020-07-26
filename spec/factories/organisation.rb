FactoryBot.define do
  factory :organisation do
    name { FFaker::Company.name }
  end
end
