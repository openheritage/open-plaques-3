describe Person, type: :model do
  let (:john_smith) { build :person }

  describe '#full_name' do
    context 'a person' do
      it 'has their name displayed as-is' do
        expect(john_smith.full_name).to eq('John Smith')
      end
    end

    context 'with a title' do
      let (:is_a_smiter) { build :role, name: 'Smiter', role_type: 'title' }
      before do
        john_smith.roles << is_a_smiter
      end
      it 'does not automatically get it displayed before their name' do
        expect(john_smith.full_name).to eq('John Smith')
      end
    end

    context 'with a title that has a prefix' do
      let (:is_a_smiter) { build :role, name: 'Smiter', prefix: 'Smt', role_type: 'title' }
      before do
        john_smith.roles << is_a_smiter
      end
      it 'has the abbreviated title displayed before their name' do
        expect(john_smith.full_name).to eq('Smt John Smith')
      end
    end

#    context 'with two different titles confering the same prefix' do
#      let (:is_a_smiter) { build :role, name: 'Smiter', prefix: 'Smt', role_type: 'title' }
#      let (:is_a_wolverine) { build :role, name: 'Wolverine', prefix: 'Smt', role_type: 'title' }
#      before do
#        john_smith.roles << is_a_smiter
#        john_smith.roles << is_a_wolverine
#      end
#      it 'has the title displayed once' do
#        expect(john_smith.full_name).to eq('Smt John Smith')
#      end
#    end

  end
end
