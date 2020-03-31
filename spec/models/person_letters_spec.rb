require 'rails_helper'

describe Person, type: :model do
  let(:a_person) { build :person }

  describe '#letters' do
    context 'a person with no roles' do
      it 'has no letters after their name' do
        expect(a_person.letters).to eq('')
      end
    end

    context 'a person with no role with a suffix' do
      let(:boodle) { build :role, name: 'Boodle' }
      let(:toodle) { build :role, name: 'Toodle' }
      let(:pip) { build :role, name: 'Pip' }
      before do
        a_person.roles << boodle
        a_person.roles << toodle
        a_person.roles << pip
      end
      it 'has no letters after their name' do
        expect(a_person.letters).to eq('')
      end
    end

    context 'a person with a mix of roles with and without suffix' do
      let(:boodle) { build :role, name: 'Boodle', prefix: 'Boo' }
      let(:toodle) { build :role, name: 'Toodle', suffix: 'Td' }
      let(:pip) { build :role, name: 'Pip' }
      before do
        a_person.roles << boodle
        a_person.roles << toodle
        a_person.roles << pip
      end
      it 'has letters after their name' do
        expect(a_person.letters).to eq('Td')
      end
    end

    context 'multiple roles with a suffix' do
      let(:boodle) { build :role, name: 'Boodle', suffix: 'Boo' }
      let(:toodle) { build :role, name: 'Toodle', suffix: 'Td' }
      let(:pip) { build :role, name: 'Pip' }
      before do
        a_person.roles << boodle
        a_person.roles << toodle
        a_person.roles << pip
      end
      it 'lists suffixed roles as letters' do
        expect(a_person.letters).to eq('Boo Td')
      end
    end

    context 'same suffix twice' do
      let(:boodle) { build :role, name: 'Boodle', suffix: 'Boo', priority: 5 }
      let(:poodle) { build :role, name: 'Poodle', suffix: 'Boo', priority: 5 }
      let(:toodle) { build :role, name: 'Toodle', suffix: 'Td', priority: 4 }
      let(:pip) { build :role, name: 'Pip' }
      before do
        a_person.roles << boodle
        a_person.roles << poodle
        a_person.roles << toodle
        a_person.roles << pip
      end
      it 'lists suffixed roles as letters' do
        expect(a_person.letters).to eq('Boo Td')
      end
    end

    context 'a person with a number of prioritised roles applied in priority order' do
      let(:om) { build :role, suffix: 'OM', priority: 10, name: 'Order of Merit recipient' }
      let(:gcsi) { build :role, suffix: 'GCSI', priority: 9, name: 'Knight Grand Commander of The Star of India' }
      let(:cb) { build :role, suffix: 'CB', priority: 8, name: 'Companion of the Order of the Bath' }
      let(:prs) { build :role, suffix: 'PRS', priority: 7, name: 'President of The Royal Society' }
      before do
        a_person.roles << om
        a_person.roles << gcsi
        a_person.roles << cb
        a_person.roles << prs
      end
      it 'lists suffixed roles as letters in priority order' do
        expect(a_person.letters).to eq('OM GCSI CB PRS')
      end
    end

    context 'a person with a number of prioritised roles applied in non-priority order' do
      let(:om) { build :role, suffix: 'OM', priority: 10, name: 'Order of Merit recipient' }
      let(:gcsi) { build :role, suffix: 'GCSI', priority: 9, name: 'Knight Grand Commander of The Star of India' }
      let(:cb) { build :role, suffix: 'CB', priority: 8, name: 'Companion of the Order of the Bath' }
      let(:prs) { build :role, suffix: 'PRS', priority: 7, name: 'President of The Royal Society' }
      before do
        a_person.roles << cb
        a_person.roles << prs
        a_person.roles << om
        a_person.roles << gcsi
      end
      it 'lists suffixed roles as letters in priority order' do
        expect(a_person.letters).to eq('OM GCSI CB PRS')
      end
    end
  end
end
