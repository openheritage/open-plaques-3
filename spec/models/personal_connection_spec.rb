describe PersonalConnection, type: :model do
  it 'has a valid factory' do
    expect(create(:personal_connection)).to be_valid
  end
end
