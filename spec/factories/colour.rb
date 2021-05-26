FactoryBot.define do
  factory :colour do
    name { FFaker::Color.name }
  end
end
