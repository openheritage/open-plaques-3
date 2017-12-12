describe Role, type: :model do
  it 'has a valid factory' do
    expect(create(:role)).to be_valid
  end
  describe '#animal?' do
    let (:role) { build :role }
    context 'with no content' do
      it 'is not' do
        expect(role.animal?).to be_falsey
      end
    end
  end
end
