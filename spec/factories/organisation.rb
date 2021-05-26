FactoryBot.define do
  factory :organisation do
    name { FFaker::Company.name }
    description { FFaker::CheesyLingo.sentence }
  end
end
