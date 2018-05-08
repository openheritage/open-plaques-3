describe Role, type: :model do
  it 'has a valid factory' do
    expect(create(:role)).to be_valid
  end
  describe '#animal?' do
    context 'with no content' do
      let (:role) { build :role }
      it 'is not an animal' do
        expect(role.animal?).to be_falsey
      end
    end
    context 'a person' do
      let (:a_person) { build :role, role_type: 'person' }
      it 'is not an animal' do
        expect(a_person.animal?).to be_falsey
      end
    end
    context 'a duck' do
      let (:a_duck) { build :role, role_type: 'animal' }
      it 'is an animal' do
        expect(a_duck.animal?).to be_truthy
      end
    end
  end
end
