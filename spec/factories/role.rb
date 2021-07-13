FactoryBot.define do
  factory :role do
    name { FFaker::CheesyLingo.words(3).join(' ') }
  end

  factory :baronet, parent: :role do
    name { 'baronet' }
    prefix { 'Sir' }
    role_type { 'title' }
  end

  factory :vicar, parent: :role do
    name { 'vicar' }
    prefix { 'Revd' }
    role_type { 'clergy' }
  end

  factory :a_person, class: :role do
    role_type { 'person' }
  end

  factory :farmer, parent: :role do
    name { 'farmer' }
    role_type { 'person' }
  end

  factory :actor, parent: :role do
    name { 'actor' }
    role_type { 'person' }
  end

  factory :dog, class: :role do
    name { 'dog' }
    role_type { 'animal' }
  end

  factory :duck, class: :role do
    name { 'duck' }
    role_type { 'animal' }
  end

  factory :building, parent: :role do
    name { 'building' }
    role_type { 'place' }
  end
end
