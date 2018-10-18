FactoryBot.define do
  factory :personal_connection do
    person
    association :verb, factory: :lived
    plaque
  end
end
