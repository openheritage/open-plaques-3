require 'rails_helper'

describe Person, type: :model do
  let(:a_person) { build :person }
  let(:john_smith) { build :person, name: 'John Smith' }

  it 'has a valid factory' do
    expect(create(:person)).to be_valid
  end

  describe '#full_name' do
    context 'a Baronet' do
      before do
        a_person.roles << (build :baronet)
      end
      it 'is referred to as a Sir' do
        expect(a_person.full_name).to eq("Sir #{a_person.name}")
      end
    end

    context 'a vicar' do
      before do
        a_person.roles << (build :vicar)
      end
      it 'is referred to as a Revd' do
        expect(a_person.full_name).to eq("Revd #{a_person.name}")
      end
    end

    context 'a member of the clergy who has been ennobled' do
      before do
        a_person.roles << (build :vicar)
        a_person.roles << (build :baronet)
      end
      it 'does not get called a Sir' do
        expect(a_person.full_name).to eq("Revd #{a_person.name}")
      end
    end

    context 'a member of the Commonwealth who has been ennobled' do
      it 'does not get called Sir/Lady'
    end

    context 'with a title' do
      let(:smiter) { build :role, name: 'Smiter', role_type: 'title' }
      before do
        a_person.roles << smiter
      end
      it 'does not automatically get it displayed before their name' do
        expect(a_person.full_name).to eq(a_person.name)
      end
    end

    context 'with a title that has a prefix' do
      let(:smiter) { build :role, name: 'Smiter', prefix: 'Smt', role_type: 'title' }
      before do
        a_person.roles << smiter
      end
      it 'has the abbreviated title displayed before their name' do
        expect(a_person.full_name).to eq("Smt #{a_person.name}")
      end
    end

    context 'with two different titles confering the same prefix' do
      let(:smiter) { build :role, name: 'Smiter', prefix: 'Smt', role_type: 'title' }
      let(:wolverine) { build :role, name: 'Wolverine', prefix: 'Smt', role_type: 'title' }
      before do
        a_person.roles << smiter
        a_person.roles << wolverine
      end
      it 'has the title displayed once' do
        expect(a_person.full_name).to eq("Smt #{a_person.name}")
      end
    end

    context 'with higher education qualifications' do
      let(:toodle) { build :role, name: 'Toodle', suffix: 'Td', role_type: 'letters' }
      before do
        a_person.roles << toodle
      end
      it 'has letters after their name' do
        expect(a_person.full_name).to eq("#{a_person.name} Td")
      end
    end

    context 'with multiple higher education qualifications' do
      let(:toodle) { build :role, name: 'Toodle', suffix: 'Td', role_type: 'letters' }
      let(:pip) { build :role, name: 'Pip', suffix: 'P', role_type: 'letters' }
      before do
        a_person.roles << toodle
        a_person.roles << pip
      end
      it 'has multiple letters after their name in the order they were added' do
        expect(a_person.full_name).to eq("#{a_person.name} Td P")
      end
    end

    context 'a princess who became queen' do
      let(:victoria) { build :person, name: 'Victoria' }
      let(:princess) { build :role, name: 'Princess', role_type: 'title', prefix: 'Princess' }
      let(:queen) { build :role, name: 'Queen of the United Kingdom', role_type: 'title', prefix: 'Queen' }
      before do
        victoria.roles << queen
        victoria.roles << princess
        victoria_princess = victoria.personal_roles.last
        victoria_princess.ended_at = '1902-01-01'
      end
      it 'is called \'Queen\' and not \'Princess Queen\'' do
        expect(victoria.full_name).to eq('Queen Victoria')
      end
    end
  end

  describe '#type' do
    context 'an actor' do
      before do
        a_person.roles << (build :actor)
      end
      it 'is a person' do
        expect(a_person.person?).to be_truthy
      end
    end

    context 'a dog' do
      before do
        a_person.roles << (build :dog)
      end
      it 'is an animal' do
        expect(a_person.type).to eq('animal')
      end
    end

    context 'a dog that acts' do
      before do
        a_person.roles << (build :dog)
        a_person.roles << (build :actor)
      end
      it 'is an animal' do
        expect(a_person.type).to eq('animal')
      end
    end

    context 'an actor that is a dog' do
      let(:lassie) { build :person }
      before do
        lassie.roles << (build :actor)
        lassie.roles << (build :dog)
      end
      it 'is an animal' do
        expect(lassie.type).to eq('animal')
      end
    end
  end

  describe '#surname_starts_with' do
    context 'a regularly named person' do
      it 'is indexed on the last word in their name' do
        john_smith.update_index
        expect(john_smith.surname_starts_with).to eq('s')
      end
    end
  end

  describe '#dead?' do
    context 'with no date of birth or death' do
      before do
        a_person.born_on = nil
        a_person.died_on = nil
      end
      it 'is still alive' do
        expect(a_person).to be_alive
      end
    end

    context 'with a date of death' do
      before do
        a_person.born_on = nil
        a_person.died_on = Date.new(2009, 1, 1)
      end
      it 'is dead' do
        expect(a_person).to be_dead
      end
    end

    context 'with a date of death and a date of birth' do
      before do
        a_person.born_on = Date.new(1932, 7, 8)
        a_person.died_on = Date.new(2009, 1, 1)
      end
      it 'is dead' do
        expect(a_person).to be_dead
      end
    end

    context 'born within the last 110 years and no date of death' do
      before do
        a_person.born_on = Date.new(1980, 1, 1)
        a_person.died_on = nil
      end
      it 'is alive' do
        expect(a_person).to be_alive
      end
    end

    context 'with a date of birth before 1900' do
      before do
        a_person.born_on = Date.new(1880, 1, 1)
        a_person.died_on = nil
      end
      it 'is dead by now' do
        expect(a_person).to be_dead
      end
    end

    context 'a building built before 1900' do
      before do
        a_person.born_on = Date.new(1880, 1, 1)
        a_person.died_on = nil
        a_person.roles << (build :building)
      end
      it 'is still standing' do
        expect(a_person).to be_alive
      end
    end
  end

  describe '#age' do
    context 'with no dates' do
      it 'has unknown age' do
        a_person.born_on = nil
        a_person.died_on = nil
        expect(a_person.age).to eq('unknown')
      end
    end

    context 'with date of death only' do
      before do
        a_person.born_on = nil
        a_person.died_on = Date.new(2009, 1, 1)
      end
      it 'has unknown age' do
        expect(a_person.age).to eq('unknown')
      end
    end

    context 'born 1 March 1932 and died 4 April 2009' do
      before do
        a_person.born_on = Date.new(1932, 3, 1)
        a_person.died_on = Date.new(2009, 4, 4)
      end
      it 'died aged 77' do
        expect(a_person.age).to be == '77'
      end
    end

    context 'born 14 April 1932 and died 4 April 2009' do
      before do
        a_person.born_on = Date.new(1932, 4, 14)
        a_person.died_on = Date.new(2009, 4, 4)
      end
      it 'died aged 77' do
        expect(a_person.age).to be == '76'
      end
    end

    context 'born 29 April 1932 and died 4 April 2009' do
      before do
        a_person.born_on = Date.new(1932, 4, 29)
        a_person.died_on = Date.new(2009, 4, 4)
      end
      it 'died aged 76' do
        expect(a_person.age).to be == '76'
      end
    end

    context 'with a date of birth and no date of death' do
      before do
        a_person.born_on = Date.new(1980, 1, 1)
        a_person.died_on = nil
      end
      it 'has an age' do
        expect(a_person.age).to be > 33
      end
    end

    context 'born in 1880 with no date of death' do
      before do
        a_person.born_on = Date.new(1880, 1, 1)
        a_person.died_on = nil
      end
      it 'is of unknown age' do
        expect(a_person.age).to eq('unknown')
      end
    end

    context 'a building built in 1880' do
      before do
        a_person.born_on = Date.new(1880, 1, 1)
        a_person.died_on = nil
        a_person.roles << (build :building)
      end
      it 'is over a hundred years old' do
        expect(a_person.age).to be > 100
      end
    end
  end

  describe '#dates' do
    context 'born in 1932 and died in 2009' do
      before do
        a_person.born_on = Date.new(1932, 7, 8)
        a_person.died_on = Date.new(2009, 1, 1)
      end
      it 'is a year range' do
        expect(a_person.dates).to eq('(1932-2009)')
      end
    end

    context 'with no dates' do
      before do
        a_person.born_on = nil
        a_person.died_on = nil
      end
      it 'is nil' do
        expect(a_person.dates).to eq('')
      end
    end

    context 'who died in 2009' do
      before do
        a_person.born_on = nil
        a_person.died_on = Date.new(2009, 1, 1)
      end
      it 'is a death year' do
        expect(a_person.dates).to eq('(d.2009)')
      end
    end

    context 'born in 1980 with no date of death' do
      before do
        a_person.born_on = Date.new(1980, 1, 1)
        a_person.died_on = nil
      end
      it 'is a range \'([birth year]-present)\'' do
        expect(a_person.dates).to eq('(1980-present)')
      end
    end

    context 'a building built in 1880' do
      before do
        a_person.born_on = Date.new(1980, 1, 1)
        a_person.died_on = nil
        a_person.roles << (build :building)
      end
      it 'is a range \'([construction year]-present)\'' do
        expect(a_person.dates).to eq('(1980-present)')
      end
    end
  end

  describe '#accented_name?' do
    context 'with an accented name' do
      let(:bela_bartok) { build :person, name: 'Béla Bartók' }
      before do
        bela_bartok.aka_accented_name
      end
      it 'is accented' do
        expect(bela_bartok.accented_name?).to be_truthy
      end
    end

    context 'with an unaccented name' do
      before do
        a_person.aka_accented_name
      end
      it 'is not accented' do
        expect(a_person.accented_name?).to be_falsey
      end
    end
  end

  describe '#aka_accented_name' do
    let(:bela_bartok) { build :person, name: 'Béla Bartók' }

    context 'with an accented name' do
      before do
        bela_bartok.aka_accented_name
      end
      it 'has an unaccented version as an aka' do
        expect(bela_bartok.aka).to include('Bela Bartok')
      end
    end

    context 'with an accented name and an aka' do
      before do
        bela_bartok.aka.push('womble')
        bela_bartok.aka_accented_name
      end
      it 'has an unaccented version as an aka' do
        expect(bela_bartok.aka).to include('Bela Bartok')
      end
    end

    context 'with an unaccented name' do
      before do
        a_person.aka_accented_name
      end
      it 'has no aka' do
        expect(a_person.aka).to_not include('John Smith')
      end
    end
  end
end
