FactoryBot.define do
  factory :series do
    name { FFaker::CheesyLingo.words(3).join(' ') }
    description { FFaker::CheesyLingo.sentence }
  end
end
