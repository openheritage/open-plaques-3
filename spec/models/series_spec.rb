describe Series, type: :model do
  it 'has a valid factory' do
    expect(create(:series)).to be_valid
  end
end
