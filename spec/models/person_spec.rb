describe Person, type: :model do
  it 'has a valid factory' do
    expect(create(:person)).to be_valid
  end

  let (:is_a_vicar) { build :role, name: 'Vicar', role_type: 'clergy', prefix: 'Revd' }
  let (:is_a_baronet) { build :role, name: 'Baronet', role_type: 'title' }

  describe '#full_name' do
    context 'a person' do
      let (:person) { build :person, name: 'John Smith' }
      it 'has their name displayed as-is' do
        expect(person.full_name).to eq('John Smith')
      end
    end

    context 'a Baronet' do
      let (:person) { build :person, name: 'John Smith' }
      let (:baronacy) { build :role, name: 'Baronet', prefix: 'Sir' }
      before do
        person.roles << baronacy
      end
      it 'is referred to as a Sir' do
        expect(person.full_name).to eq('Sir John Smith')
      end
    end

    context 'a vicar' do
      let (:person) { build :person, name: 'Malcolm McBonny' }
      before do
        person.roles << is_a_vicar
      end
      it 'is referred to as a Revd' do
        expect(person.full_name).to eq('Revd Malcolm McBonny')
      end
    end

    context 'a member of the clergy who has been ennobled' do
      let (:person) { build :person, name: 'Malcolm McBonny' }
      before do
        person.roles << is_a_vicar
        person.roles << is_a_baronet
      end
      it 'does not get called a Sir' do
        expect(person.full_name).to eq('Revd Malcolm McBonny')
      end
    end

    context 'a member of the Commonwealth who has been ennobled' do
      it 'does not get called Sir/Lady'
    end

    context 'with a title' do
      let (:person) { build :person, name: 'Harry Bean' }
      let (:is_a_smiter) { build :role, name: 'Smiter', role_type: 'title' }
      before do
        person.roles << is_a_smiter
      end
      it 'does not automatically get it displayed before their name' do
        expect(person.full_name).to eq('Harry Bean')
      end
    end

    context 'with a title that has a prefix' do
      let (:person) { build :person, name: 'Harry Bean' }
      let (:is_a_smiter) { build :role, name: 'Smiter', prefix: 'Smt', role_type: 'title' }
      before do
        person.roles << is_a_smiter
      end
      it 'has the abbreviated title displayed before their name' do
        expect(person.full_name).to eq('Smt Harry Bean')
      end
    end

    context 'with two different titles confering the same prefix' do
      before do
        @person = Person.new(name: 'Harry Bean')
        @role = Role.new(
          name: 'Smiter', prefix: 'Smt', role_type: 'title'
        )
        @person.roles << @role
        @role2 = Role.new(
          name: 'Wolverine', prefix: 'Smt', role_type: 'title'
        )
        @person.roles << @role2
      end
      it 'has the title displayed once before their name' do
        expect(@person.full_name).to eq('Smt Harry Bean')
      end
    end

    context 'with higher education qualifications' do
      before do
        @person = Person.new(name: 'John Smith')
        @role = Role.new(name: 'Toodle', suffix: 'Td', role_type: 'letters')
        @person.roles << @role
      end
      it 'has letters after their name' do
        expect(@person.full_name).to eq('John Smith Td')
      end
    end

    context 'with multiple higher education qualifications' do
      before do
        @person = Person.new(name: 'John Smith')
        @role = Role.new(name: 'Toodle', suffix: 'Td', role_type: 'letters')
        @person.roles << @role
        @role = Role.new(name: 'Pip', suffix: 'P', role_type: 'letters')
        @person.roles << @role
      end
      it 'has multiple letters after their name in the order they were added' do
        expect(@person.full_name).to eq('John Smith Td P')
      end
    end

    context 'a princess who became queen' do
      before do
        @victoria = Person.new(name: 'Victoria')
        @victoria.roles << Role.new(
          name: 'Queen of the United Kingdom',
          prefix: 'Queen',
          role_type: 'title'
        )
        @princess = Role.new(
          name: 'Princess',
          prefix: 'Princess',
          role_type: 'title'
        )
        @victoria.roles << @princess
        @victoria_is_a_princess = @victoria.personal_roles.last
        @victoria_is_a_princess.ended_at = '1902-01-01'
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

  describe '#letters' do
    context 'no role' do
      before do
        @person = Person.new(name: 'Frankie')
      end
      it 'lists suffixed roles as letters' do
        expect(@person.letters).to eq('')
      end
    end

    context 'no role with a suffix' do
      before do
        @person = Person.new(name: 'Frankie')
        @person.roles << Role.new(name: 'Boodle')
        @person.roles << Role.new(name: 'Toodle')
        @person.roles << Role.new(name: 'Pip')
      end
      it 'lists suffixed roles as letters' do
        expect(@person.letters).to eq('')
      end
    end

    context 'a mix of roles with and without suffix' do
      before do
        @person = Person.new(name: 'Frankie')
        @person.roles << Role.new(name: 'Boodle', prefix: 'Boo')
        @person.roles << Role.new(name: 'Toodle', suffix: 'Td')
        @person.roles << Role.new(name: 'Pip')
      end
      it 'lists suffixed roles as letters' do
        expect(@person.letters).to eq('Td')
      end
    end

    context 'multiple roles with a suffix' do
      before do
        @person = Person.new(name: 'Frankie')
        @person.roles << Role.new(name: 'Boodle', suffix: 'Boo')
        @person.roles << Role.new(name: 'Toodle', suffix: 'Td')
        @person.roles << Role.new(name: 'Pip')
      end
      it 'lists suffixed roles as letters' do
        expect(@person.letters).to eq('Boo Td')
      end
    end

    context 'same suffix twice' do
      before do
        @person = Person.new(name: 'Frankie')
        @person.roles << Role.new(name: 'Boodle', suffix: 'Boo')
        @person.roles << Role.new(name: 'Poodle', suffix: 'Boo')
        @person.roles << Role.new(name: 'Toodle', suffix: 'Td')
        @person.roles << Role.new(name: 'Pip')
      end
      it 'lists suffixed roles as letters' do
        #        expect(@person.letters).to eq('Boo Td')
      end
    end

    # Sir Joseph Dalton Hooker OM GCSI CB PRS

    context 'Sir Joseph Dalton Hooker OM GCSI CB PRS' do
      before do
        @person = Person.new(name: 'Joseph Dalton Hooker')
        @person.roles << Role.new(
          name: 'Order of Merit recipient', suffix: 'OM'
        )
        @person.roles << Role.new(
          name: 'Knight Grand Commander of The Star of India', suffix: 'GCSI'
        )
        @person.roles << Role.new(
          name: 'Companion of the Order of the Bath', suffix: 'CB'
        )
        @person.roles << Role.new(
          name: 'President of The Royal Society', suffix: 'PRS'
        )
      end
      it 'lists suffixed roles as letters' do
        expect(@person.letters).to eq('OM GCSI CB PRS')
      end
    end

    context 'Sir Joseph Dalton Hooker OM GCSI CB PRS' do
      before do
        @person = Person.new(name: 'Joseph Dalton Hooker')
        @person.roles << Role.new(
          name: 'Order of Merit recipient', suffix: 'OM', priority: 90
        )
        @person.roles << Role.new(
          name: 'President of The Royal Society', suffix: 'PRS'
        )
        @person.roles << Role.new(
          name: 'Companion of the Order of the Bath', suffix: 'CB', priority: 70
        )
        @person.roles << Role.new(
          name: 'Knight Grand Commander of The Star of India',
          suffix: 'GCSI',
          priority: 80
        )
      end
      it 'lists suffixed roles as letters' do
        expect(@person.letters).to eq('OM GCSI CB PRS')
      end
    end
  end

  describe '#clergy?' do
    context 'a vicar' do
      before do
        @person = Person.new(name: 'Malcolm McBonny')
        @person.roles << Role.new(
          name: 'vicar', role_type: 'clergy', abbreviation: 'Revd'
        )
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
        @person.roles << Role.new(
          name: 'vicar', role_type: 'clergy', abbreviation: 'Revd'
        )
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
    context 'with no dates' do
      before do
        @person = Person.new
      end
      it 'is still alive' do
        expect(@person).to be_alive
      end
    end

    context 'with a date of death' do
      before do
        @person = Person.new
        @person.died_on = Date.new(2009, 1, 1)
      end
      it 'is dead' do
        expect(@person).to be_dead
      end
    end

    context 'with a date of death and a date of birth' do
      before do
        @person = Person.new
        @person.born_on = Date.new(1932, 7, 8)
        @person.died_on = Date.new(2009, 1, 1)
      end
      it 'is dead' do
        expect(@person).to be_dead
      end
    end

    context 'with a date of birth and no date of death' do
      before do
        @person = Person.new
        @person.born_on = Date.new(1980, 1, 1)
      end
      it 'is alive' do
        expect(@person).to be_alive
      end
    end

    context 'with a date of birth before 1900' do
      before do
        @person = Person.new
        @person.born_on = Date.new(1880, 1, 1)
      end
      it 'is dead by now' do
        expect(@person).to be_dead
      end
    end

    context 'a building built before 1900' do
      before do
        @person = Person.new
        @person.born_on = Date.new(1880, 1, 1)
        @person.roles << Role.new(name: 'building', role_type: 'thing')
      end
      it 'is still standing' do
        expect(@person).to be_alive
      end
    end
  end

  describe '#age' do
    context 'with no dates' do
      before do
        @person = Person.new
      end
      it 'is unknown' do
        expect(@person.age).to eq('unknown')
      end
    end

    context 'with date of death only' do
      before do
        @person = Person.new
        @person.died_on = Date.new(2009, 1, 1)
      end
      it 'is unknown' do
        expect(@person.age).to eq('unknown')
      end
    end

    context 'born 1 March 1932 and died 4 April 2009' do
      before do
        @person = Person.new
        @person.born_on = Date.new(1932, 3, 1)
        @person.died_on = Date.new(2009, 4, 4)
      end
      it 'was 77' do
        expect(@person.age).to be == '77'
      end
    end

    context 'born 14 April 1932 and died 4 April 2009' do
      before do
        @person = Person.new
        @person.born_on = Date.new(1932, 4, 14)
        @person.died_on = Date.new(2009, 4, 4)
      end
      it 'was 76' do
        expect(@person.age).to be == '76'
      end
    end

    context 'born 29 April 1932 and died 4 April 2009' do
      before do
        @person = Person.new
        @person.born_on = Date.new(1932, 4, 29)
        @person.died_on = Date.new(2009, 4, 4)
      end
      it 'was 76' do
        expect(@person.age).to be == '76'
      end
    end

    context 'with a date of birth and no date of death' do
      before do
        @person = Person.new
        @person.born_on = Date.new(1980, 1, 1)
      end
      it 'has an age' do
        expect(@person.age).to be > 33
      end
    end

    context 'born in 1880 with no date of death' do
      before do
        @person = Person.new
        @person.born_on = Date.new(1880, 1, 1)
      end
      it 'is of unknown age' do
        expect(@person.age).to eq('unknown')
      end
    end

    context 'a building built in 1880' do
      let (:building) { build :person }
      before do
        building.born_on = Date.new(1880, 1, 1)
        building.roles << Role.new(name: 'building', role_type: 'thing')
      end
      it 'is over a hundred years old' do
        expect(building.age).to be > 100
      end
    end
  end

  describe '#dates' do
    context 'born in 1932 and died in 2009' do
      let (:person) { build :person }
      before do
        person.born_on = Date.new(1932, 7, 8)
        person.died_on = Date.new(2009, 1, 1)
      end
      it 'is a year range' do
        expect(person.dates).to eq('(1932-2009)')
      end
    end

    context 'with no dates' do
      let (:person) { build :person }
      it 'is nil' do
        expect(person.dates).to eq(nil)
      end
    end

    context 'who died in 2009' do
      let (:person) { build :person, died_on: Date.new(2009, 1, 1) }
      it 'is a death year' do
        expect(person.dates).to eq('(d.2009)')
      end
    end

    context 'born in 1980 with no date of death' do
      let (:person) { build :person, born_on: Date.new(1980, 1, 1) }
      it 'is a range \'([birth year]-present)\'' do
        expect(person.dates).to eq('(1980-present)')
      end
    end

    context 'a building built in 1880' do
      let (:person) { build :person, born_on: Date.new(1880, 1, 1) }
      let (:role) { build :role, name: 'building', role_type: 'place' }
      before do
        person.roles << role
      end
      it 'is a range \'([construction year]-present)\'' do
        expect(person.dates).to eq('(1880-present)')
      end
    end
  end

  describe '#accented_name?' do
    context 'with an accented name' do
      let (:person) { build :person, name: 'Béla Bartók' }
      before do
        person.aka_accented_name
      end
      it 'is accented' do
        expect(person.accented_name?).to be_truthy
      end
    end

    context 'with an unaccented name' do
      let (:person) { build :person, name: 'John Smith' }
      before do
        person.aka_accented_name
      end
      it 'is not accented' do
        expect(person.accented_name?).to be_falsey
      end
    end
  end

  describe '#aka_accented_name' do
    context 'with an accented name' do
      let (:person) { build :person, name: 'Béla Bartók' }
      before do
        person.aka_accented_name
      end
      it 'has an unaccented version as an aka' do
        expect(person.aka).to include('Bela Bartok')
      end
    end

    context 'with an accented name and an aka' do
      let (:person) { build :person, name: 'Béla Bartók' }
      before do
        person.aka.push('womble')
        person.aka_accented_name
      end
      it 'has an unaccented version as an aka' do
        expect(person.aka).to include('Bela Bartok')
      end
    end

    context 'with an unaccented name' do
      let (:person) { build :person, name: 'John Smith' }
      before do
        person.aka_accented_name
      end
      it 'has no aka' do
        expect(person.aka).to_not include('Bela Bartok')
      end
    end
  end

  describe '#fill_wikidata_id' do
    context 'an unfindable name' do
      let(:person) { build :person, name: 'zdfgad'}
      before do
        person.fill_wikidata_id
      end
      it 'has no Wikidata' do
        expect(person.wikidata_id).to eq(nil)
      end
    end
    context 'an ambiguous name' do
      let(:person) { build :person, name: 'John Smith'}
      before do
        person.fill_wikidata_id
      end
      it 'has no Wikidata' do
        expect(person.wikidata_id).to eq(nil)
      end
    end
    context 'an unambiguous name' do
      let(:person) { build :person, name: 'Myra Hess'}
      before do
        person.fill_wikidata_id
      end
      it 'has Wikidata' do
        expect(person.wikidata_id).to eq("Q269848")
      end
    end
  end

  describe '#wikipedia_url' do
    context 'with no wikidata id' do
      let(:person) { build :person }
      it 'has no Wikidata' do
        expect(person.wikipedia_url).to eq(nil)
      end
    end
    context 'with a wikidata id' do
      let(:person) { build :person, wikidata_id: "Q269848" }
      it 'has no Wikidata' do
        expect(person.wikipedia_url).to eq("https://en.wikipedia.org/wiki/Myra_Hess")
      end
    end
  end

  describe '#dbpedia_abstract' do
    context 'with no wikidata id' do
      let(:person) { build :person }
      it 'has no Wikidata' do
        expect(person.dbpedia_abstract).to eq(nil)
      end
    end
    context 'with a wikidata id' do
      let(:person) { build :person, wikidata_id: "Q2063684" }
      it 'has no Wikidata' do
        expect(person.dbpedia_abstract).to include("Matilda Alice Powles")
      end
    end
  end

end
