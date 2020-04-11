FactoryBot.define do
  factory :photo do
    url { "https://www.geograph.org.uk/photo/#{rand(3000)}" }
  end
end
