require 'rails_helper'

describe Person, type: :model do
  let(:a_person) { build :person }

  describe '#full_name' do
    context 'a person' do
      it 'has their name displayed as-is' do
        expect(a_person.full_name).to eq(a_person.name)
      end
    end

    context 'with a title' do
      let(:is_a_smiter) { build :role, name: 'Smiter', role_type: 'title' }
      before do
        a_person.roles << is_a_smiter
      end
      it 'does not automatically get it displayed before their name' do
        expect(a_person.full_name).to eq(a_person.name)
      end
    end

    context 'with a title that has a prefix' do
      let(:is_a_smiter) { build :role, name: 'Smiter', prefix: 'Smt', role_type: 'title' }
      before do
        a_person.roles << is_a_smiter
      end
      it 'has the abbreviated title displayed before their name' do
        expect(a_person.full_name).to eq("Smt #{a_person.name}")
      end
    end
  end
end
