FactoryBot.define do
  factory :verb do
    name { FFaker::DizzleIpsum.words(3).join(' ') }
  end

  factory :lived, class: :verb do
    name { 'lived' }
  end
end
