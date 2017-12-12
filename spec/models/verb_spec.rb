describe Verb, type: :model do
  it 'has a valid factory' do
    expect(create(:verb)).to be_valid
  end
end
