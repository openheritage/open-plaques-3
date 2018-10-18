FactoryBot.define do
  factory :role do
    name {'adsfsd'}
  end

  factory :title, parent: :role do
    role_type {'title'}
  end

  factory :baronet, parent: :title do
    name {'baronet'}
    prefix {'Sir'}
  end

  factory :clergy, parent: :role do
    role_type {'clergy'}
  end

  factory :vicar, parent: :clergy do
    name {'vicar'}
    prefix {'Revd'}
  end

  factory :a_person, class: :role do
    role_type {'person'}
  end

  factory :farmer, parent: :a_person do
    name {'farmer'}
  end

  factory :actor, parent: :a_person do
    name {'actor'}
  end

  factory :animal, class: :role do
    role_type {'animal'}
  end

  factory :dog, parent: :animal do
    name {'dog'}
  end

  factory :place, class: :role do
    role_type {'place'}
  end

  factory :building, parent: :place do
    name {'Mansfield House'}
  end
end
