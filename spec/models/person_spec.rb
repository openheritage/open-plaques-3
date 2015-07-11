require 'spec_helper'

describe Person do
  
  describe '#full_name' do
    context 'a person' do
      before do
        @person = Person.new(name: 'John Smith')
      end
      it 'has their name displayed as-is' do
        expect(@person.full_name).to eq('John Smith')
      end
    end

    context 'a Baronet' do
      before do
        @person = Person.new(name: 'John Smith')
        @person.roles << Role.new(name: 'Baronet', prefix: 'Sir')
      end
      it 'is referred to as a Sir' do
        expect(@person.full_name).to eq('Sir John Smith')
      end
    end

    context 'a Baroness' do
      before do
        @person = Person.new(name: 'Ethel Smith')
        @person.roles << Role.new(name: 'Baroness', prefix: 'Lady')
      end
      it 'is referred to as a Lady' do
        expect(@person.full_name).to eq('Lady Ethel Smith')
      end
    end

    context 'a vicar' do
      before do
        @person = Person.new(name: 'Malcolm McBonny')
        @person.roles << Role.new(name: 'Vicar', role_type: 'clergy', prefix: 'Revd')
      end
      it 'is referred to as a Revd' do
        expect(@person.full_name).to eq('Revd Malcolm McBonny')
      end
    end

    context 'a member of the clergy who has been ennobled' do
      before do
        @person = Person.new(name: 'Malcolm McBonny')
        @person.roles << Role.new(name: 'Vicar', role_type: 'clergy', prefix: 'Revd')
        @person.roles << Role.new(name: 'Baronet', prefix: 'Sir')
      end
      it 'does not get called a Sir/Lady' do
        expect(@person.full_name).to eq('Revd Malcolm McBonny')
      end
    end

    context 'a member of the Commonwealth who has been ennobled' do
      it 'does not get called Sir/Lady'
    end

    context 'a person with a role that confers a title' do
      before do
        @person = Person.new(name: 'Harry Bean')
        @role = Role.new(name: 'Smiter', role_type: 'title')
        @person.roles << @role
      end
      it 'has the title displayed before their name' do
        expect(@person.full_name).to eq('Smiter Harry Bean')
      end
    end

    context 'a person with a title that can be abbreviated' do
      before do
        @person = Person.new(name: 'Harry Bean')
        @role = Role.new(name: 'Smiter', abbreviation: 'Smt', role_type: 'title')
        @person.roles << @role
      end
      it 'has the abbreviated title displayed before their name' do
        expect(@person.full_name).to eq('Smt Harry Bean')
      end
    end

    context 'a person with two different titles confering the same prefix' do
      before do
        @person = Person.new(name: 'Harry Bean')
        @role = Role.new(name: 'Smiter', abbreviation: 'Smt', role_type: 'title')
        @person.roles << @role
        @role2 = Role.new(name: 'Wolverine', abbreviation: 'Smt', role_type: 'title')
        @person.roles << @role2
      end
      it 'has the title displayed once before their name' do
        expect(@person.full_name).to eq('Smt Harry Bean')
      end
    end

    context 'a person with higher education qualifications' do
      before do
        @person = Person.new(name: 'John Smith')
        @role = Role.new(name: 'Toodle', suffix: 'Td', role_type: 'letters')
        @person.roles << @role
      end
      it 'has letters after their name' do
        expect(@person.full_name).to eq('John Smith Td')
      end
    end
 
    context 'a person with multiple higher education qualifications' do
      before do
        @person = Person.new(name: 'John Smith')
        @role = Role.new(name: 'Toodle', suffix: 'Td', role_type: 'letters')
        @person.roles << @role
        @role = Role.new(name: 'Pip', suffix: 'P', role_type: 'letters')
        @person.roles << @role
      end
      it 'has multiple letters after their name (in the order they were added)' do
        expect(@person.full_name).to eq('John Smith Td P')
      end
    end
 
    context 'a princess who became queen' do
      before do
        @victoria = Person.new(name: 'Victoria')
        @victoria.roles << Role.new(name: 'Queen of the United Kingdom', abbreviation: 'Queen', role_type: 'title')
        @princess = Role.new(name: 'Princess', abbreviation: 'Princess', role_type: 'title')
        @victoria.roles << @princess
        @victoria_is_a_princess = @victoria.personal_roles.last
        @victoria_is_a_princess.ended_at = "1902-01-01"
      end
      it 'is called \'Queen\' and not \'Princess Queen\'' do
        expect(@victoria.full_name).to eq('Queen Victoria')
      end
    end

    context 'letters after your name' do
      before do
        @person = Person.new(name: 'Frankie')
        @role = Role.new(name: 'Toodle', abbreviation: 'Td')
        @person.roles << @role
      end
      it 'joins the title and name' do
        expect(@person.full_name).to eq('Frankie')
      end
    end
  end

  describe '#clergy?' do
    context 'a vicar' do
      before do
        @person = Person.new(name: 'Malcolm McBonny')
        @person.roles << Role.new(name: 'vicar', role_type: 'clergy', abbreviation: 'Revd')
      end
      it 'is in the clergy' do
        expect(@person).to be_clergy
      end
    end

    context 'a farmer' do
      before do
        @person = Person.new(name: 'Malcolm McBonny')
        @person.roles << Role.new(name: 'farmer')
      end
      it 'is not in the clergy' do
        expect(@person).to_not be_clergy
      end
    end

    context 'a farmer who is also a vicar' do
      before do
        @person = Person.new(name: 'Malcolm McBonny')
        @person.roles << Role.new(name: 'farmer')
        @person.roles << Role.new(name: 'vicar', role_type: 'clergy', abbreviation: 'Revd')
      end
      it 'is in the clergy' do
        expect(@person).to be_clergy
      end
    end
  end

  describe '#type' do
    context 'a subject' do
      before do
        @person = Person.new(name: 'Malcolm McBonny')
      end
      it 'is assumed to be a man' do
        expect(@person.type).to eq('man')
      end
    end

    context 'an actor' do
      before do
        @person = Person.new(name: 'Malcolm McBonny')
        @person.roles << Role.new(name: 'actor')
      end
      it 'is a person' do
        expect(@person.type).to eq('man')
      end
    end

    context 'a dog' do
      before do
        @person = Person.new(name: 'Malcolm McBonny')
        @person.roles << Role.new(name: 'dog', role_type: 'animal')
      end
      it 'is an animal' do
        expect(@person.type).to eq('animal')
      end
    end

    context 'a dog that acts' do
      before do
        @person = Person.new(name: 'Malcolm McBonny')
        @person.roles << Role.new(name: 'dog', role_type: 'animal')
        @person.roles << Role.new(name: 'actor')
      end
      it 'is an animal' do
        expect(@person.type).to eq('animal')
      end
    end

    context 'an actor that is a dog' do
      before do
        @person = Person.new(name: 'Malcolm McBonny')
        @person.roles << Role.new(name: 'actor')
        @person.roles << Role.new(name: 'dog', role_type: 'animal')
      end
      it 'is an animal' do
        expect(@person.type).to eq('animal')
      end
    end
  end

  describe '#surname_starts_with' do
    context 'a regularly named person' do
      before do
        @person = Person.new(name: 'John Smith')
      end
      it 'is indexed on the last word in their name' do
        @person.update_index
        expect(@person.surname_starts_with).to eq('s')
      end
    end
  end

  describe '#dead?' do
    context 'a person with no dates' do
      before do
        @person = Person.new()
      end
      it 'is still alive' do
        expect(@person).to be_alive
      end
    end

    context 'a person with a date of death' do
      before do
        @person = Person.new()
        @person.died_on = Date.new(2009, 1, 1)
      end
      it 'is dead' do
        expect(@person).to be_dead
      end
    end

    context 'a person with a date of death and a date of birth' do
      before do
        @person = Person.new()
        @person.born_on = Date.new(1932, 7, 8)
        @person.died_on = Date.new(2009, 1, 1)
      end
      it 'is dead' do
        expect(@person).to be_dead
      end
    end

    context 'a person with a date of birth and no date of death' do
      before do
        @person = Person.new()
        @person.born_on = Date.new(1980, 1, 1)
      end
      it 'is alive' do
        expect(@person).to be_alive
      end
    end

    context 'a person with a date of birth before 1900' do
      before do
        @person = Person.new()
        @person.born_on = Date.new(1880, 1, 1)
      end
      it 'is dead by now' do
        expect(@person).to be_dead
      end
    end

    context 'a building built before 1900' do
      before do
        @person = Person.new()
        @person.born_on = Date.new(1880, 1, 1)
        @person.roles << Role.new(name: 'building', role_type: 'thing')
      end
      it 'is still standing' do
        expect(@person).to be_alive
      end
    end
  end

  describe '#age' do
    context 'a person with no dates' do
      before do
        @person = Person.new()
      end
      it 'is of unknown age' do
        expect(@person.age).to eq('unknown')
      end
    end

    context 'a person with only a date of death' do
      before do
        @person = Person.new()
        @person.died_on = Date.new(2009, 1, 1)
      end
      it 'is of unknown age' do
        expect(@person.age).to eq('unknown')
      end
    end

    context 'a person born in 1932 and died in 2009' do
      before do
        @person = Person.new()
        @person.born_on = Date.new(1932, 7, 8)
        @person.died_on = Date.new(2009, 1, 1)
      end
      it 'was 77' do
        expect(@person.age).to be > 76
      end
    end

    context 'a person with a date of birth and no date of death' do
      before do
        @person = Person.new()
        @person.born_on = Date.new(1980, 1, 1)
      end
      it 'has an age' do
        expect(@person.age).to be > 33
      end
    end

    context 'a person born in 1880 with no date of death' do
      before do
        @person = Person.new()
        @person.born_on = Date.new(1880, 1, 1)
      end
      it 'is of unknown age' do
        expect(@person.age).to eq('unknown')
      end
    end

    context 'a building built before 1900' do
      before do
        @person = Person.new()
        @person.born_on = Date.new(1880, 1, 1)
        @person.roles << Role.new(name: 'building', role_type: 'thing')
      end
      it 'is over a hundred years old' do
        expect(@person.age).to be > 133
      end
    end
  end

  describe '#dates' do
    context 'a person born in 1932 and died in 2009' do
      before do
        @person = Person.new()
        @person.born_on = Date.new(1932, 7, 8)
        @person.died_on = Date.new(2009, 1, 1)
      end
      it 'displays a date range' do
        expect(@person.dates).to eq('(1932-2009)')
      end
    end

    context 'a person with no dates' do
      before do
        @person = Person.new()
      end
      it 'can\'t display a date range' do
        expect(@person.dates).to eq('')
      end
    end

    context 'a person who died in 2009' do
      before do
        @person = Person.new()
        @person.died_on = Date.new(2009, 1, 1)
      end
      it 'displays a death date' do
        expect(@person.dates).to eq('(died in 2009)')
      end
    end

    context 'a person born in 1980 with no date of death' do
      before do
        @person = Person.new()
        @person.born_on = Date.new(1980, 1, 1)
      end
      it 'displays a birth date' do
        expect(@person.dates).to eq('(born in 1980)')
      end
    end

    context 'a building built in 1880' do
      before do
        @person = Person.new()
        @person.born_on = Date.new(1880, 1, 1)
        @person.roles << Role.new(name: 'building', role_type: 'place')
      end
      it 'displays a built date' do
        expect(@person.dates).to eq('(built in 1880)')
      end
    end
  end

end
