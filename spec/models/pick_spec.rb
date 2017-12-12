describe Pick, type: :model do
  it 'has a valid factory' do
    expect(create(:pick)).to be_valid
  end
end
