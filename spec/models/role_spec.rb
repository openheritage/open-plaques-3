require 'rails_helper'

describe Role, type: :model do
  it 'has a valid factory' do
    expect(create(:role)).to be_valid
  end

  describe 'with no content' do
    let(:a_role) { build :role }
    it 'is a person' do
      expect(a_role.person?).to be_truthy
    end
    it 'is a type of person' do
      expect(a_role.type).to eq 'person'
    end
    it 'is not an animal' do
      expect(a_role.animal?).to be_falsey
    end
    it 'is not family' do
      expect(a_role.family?).to be_falsey
    end
  end

  describe 'a group' do
    let(:a_group) { build :role, name: 'friends', role_type: 'group' }
    it 'is not a person' do
      expect(a_group.person?).to be_falsey
    end
  end

  describe 'a person' do
    let(:a_person) { build :role, name: 'drummer', role_type: 'person' }
    it 'is a person' do
      expect(a_person.person?).to be_truthy
    end
    it 'is not an animal' do
      expect(a_person.animal?).to be_falsey
    end
    it 'is not (necessarily) family' do
      expect(a_person.family?).to be_falsey
    end
  end

  describe 'a duck' do
    let(:a_duck) { build :role, name: 'duck', role_type: 'animal' }
    it 'is an animal' do
      expect(a_duck.animal?).to be_truthy
    end
    it 'is not family' do
      expect(a_duck.family?).to be_falsey
    end
  end

  describe 'a spouse' do
    let(:a_spouse) { build :role, name: 'wife', role_type: 'spouse' }
    it 'is family' do
      expect(a_spouse.family?).to be_truthy
    end
    it 'is a relationship' do
      expect(a_spouse.relationship?).to be_truthy
    end
  end

  describe 'a brother' do
    let(:a_brother) { build :role, name: 'brother' }
    it 'is family' do
      expect(a_brother.family?).to be_truthy
    end
  end

  describe 'a vicar' do
    let(:a_vicar) { build :role, name: 'vicar' }
    it 'is not family' do
      expect(a_vicar.family?).to be_falsey
    end
  end
end
