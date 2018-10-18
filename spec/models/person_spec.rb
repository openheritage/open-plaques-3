describe Person, type: :model do
  let (:john_smith) { build :person }

  it 'has a valid factory' do
    expect(create :person).to be_valid
  end

  describe '#full_name' do
    context 'a person' do
      it 'has their name displayed as-is' do
        expect(john_smith.full_name).to eq 'John Smith'
      end
    end

    context 'a Baronet' do
      before do
        john_smith.roles << (build :baronet)
      end
      it 'is referred to as a Sir' do
        expect(john_smith.full_name).to eq 'Sir John Smith'
      end
    end

    context 'a vicar' do
      before do
        john_smith.roles << (build :vicar)
      end
      it 'is referred to as a Revd' do
        expect(john_smith.full_name).to eq('Revd John Smith')
      end
    end

    context 'a member of the clergy who has been ennobled' do
      before do
        john_smith.roles << (build :vicar)
        john_smith.roles << (build :baronet)
      end
      it 'does not get called a Sir' do
        expect(john_smith.full_name).to eq('Revd John Smith')
      end
    end

    context 'a member of the Commonwealth who has been ennobled' do
      it 'does not get called Sir/Lady'
    end

    context 'with a title' do
      let (:smiter) { build :role, name: 'Smiter', role_type: 'title' }
      before do
        john_smith.roles << smiter
      end
      it 'does not automatically get it displayed before their name' do
        expect(john_smith.full_name).to eq('John Smith')
      end
    end

    context 'with a title that has a prefix' do
      let (:smiter) { build :role, name: 'Smiter', prefix: 'Smt', role_type: 'title' }
      before do
        john_smith.roles << smiter
      end
      it 'has the abbreviated title displayed before their name' do
        expect(john_smith.full_name).to eq('Smt John Smith')
      end
    end

    context 'with two different titles confering the same prefix' do
      let (:smiter) { build :role, name: 'Smiter', prefix: 'Smt', role_type: 'title' }
      let (:wolverine) { build :role, name: 'Wolverine', prefix: 'Smt', role_type: 'title' }
      before do
        john_smith.roles << smiter
        john_smith.roles << wolverine
      end
      it 'has the title displayed once' do
        expect(john_smith.full_name).to eq('Smt John Smith')
      end
    end

    context 'with higher education qualifications' do
      let (:toodle) { build :role, name: 'Toodle', suffix: 'Td', role_type: 'letters' }
      before do
        john_smith.roles << toodle
      end
      it 'has letters after their name' do
        expect(john_smith.full_name).to eq('John Smith Td')
      end
    end

    context 'with multiple higher education qualifications' do
      let (:toodle) { build :role, name: 'Toodle', suffix: 'Td', role_type: 'letters' }
      let (:pip) { build :role, name: 'Pip', suffix: 'P', role_type: 'letters' }
      before do
        john_smith.roles << toodle
        john_smith.roles << pip
      end
      it 'has multiple letters after their name in the order they were added' do
        expect(john_smith.full_name).to eq('John Smith Td P')
      end
    end

    context 'a princess who became queen' do
      let (:victoria) { build :person, name: 'Victoria' }
      let (:princess) { build :role, name: 'Princess', role_type: 'title', prefix: 'Princess' }
      let (:is_queen) { build :role, name: 'Queen of the United Kingdom', role_type: 'title', prefix: 'Queen' }
      before do
        victoria.roles << is_queen
        victoria.roles << princess
        victoria_princess = victoria.personal_roles.last
        victoria_princess.ended_at = '1902-01-01'
      end
      it 'is called \'Queen\' and not \'Princess Queen\'' do
        expect(victoria.full_name).to eq('Queen Victoria')
      end
    end
  end

  describe '#letters' do
    context 'a person with no roles' do
      it 'has no letters after their name' do
        expect(john_smith.letters).to eq('')
      end
    end

    context 'a person with no role with a suffix' do
      let (:boodle) { build :role, name: 'Boodle' }
      let (:toodle) { build :role, name: 'Toodle' }
      let (:pip) { build :role, name: 'Pip' }
      before do
        john_smith.roles << boodle
        john_smith.roles << toodle
        john_smith.roles << pip
      end
      it 'has no letters after their name' do
        expect(john_smith.letters).to eq('')
      end
    end

    context 'a person with a mix of roles with and without suffix' do
      let (:boodle) { build :role, name: 'Boodle', prefix: 'Boo' }
      let (:toodle) { build :role, name: 'Toodle', suffix: 'Td' }
      let (:pip) { build :role, name: 'Pip' }
      before do
        john_smith.roles << boodle
        john_smith.roles << toodle
        john_smith.roles << pip
      end
      it 'has letters after their name' do
        expect(john_smith.letters).to eq('Td')
      end
    end

    context 'multiple roles with a suffix' do
      let (:boodle) { build :role, name: 'Boodle', suffix: 'Boo' }
      let (:toodle) { build :role, name: 'Toodle', suffix: 'Td' }
      let (:pip) { build :role, name: 'Pip' }
      before do
        john_smith.roles << boodle
        john_smith.roles << toodle
        john_smith.roles << pip
      end
      it 'lists suffixed roles as letters' do
        expect(john_smith.letters).to eq('Boo Td')
      end
    end

    context 'same suffix twice' do
      let (:boodle) { build :role, name: 'Boodle', suffix: 'Boo', priority: 5 }
      let (:poodle) { build :role, name: 'Poodle', suffix: 'Boo', priority: 5 }
      let (:toodle) { build :role, name: 'Toodle', suffix: 'Td', priority: 4 }
      let (:pip) { build :role, name: 'Pip' }
      before do
        john_smith.roles << boodle
        john_smith.roles << poodle
        john_smith.roles << toodle
        john_smith.roles << pip
      end
      it 'lists suffixed roles as letters' do
        expect(john_smith.letters).to eq('Boo Td')
      end
    end

    context 'a person with a number of prioritised roles applied in priority order' do
      let (:om) { build :role, suffix: 'OM', priority: 10, name: 'Order of Merit recipient' }
      let (:gcsi) { build :role, suffix: 'GCSI', priority: 9, name: 'Knight Grand Commander of The Star of India' }
      let (:cb) { build :role, suffix: 'CB', priority: 8, name: 'Companion of the Order of the Bath' }
      let (:prs) { build :role, suffix: 'PRS', priority: 7, name: 'President of The Royal Society' }
      before do
        john_smith.roles << om
        john_smith.roles << gcsi
        john_smith.roles << cb
        john_smith.roles << prs
      end
      it 'lists suffixed roles as letters in priority order' do
        expect(john_smith.letters).to eq('OM GCSI CB PRS')
      end
    end

    context 'a person with a number of prioritised roles applied in non-priority order' do
      let (:om) { build :role, suffix: 'OM', priority: 10, name: 'Order of Merit recipient' }
      let (:gcsi) { build :role, suffix: 'GCSI', priority: 9, name: 'Knight Grand Commander of The Star of India' }
      let (:cb) { build :role, suffix: 'CB', priority: 8, name: 'Companion of the Order of the Bath' }
      let (:prs) { build :role, suffix: 'PRS', priority: 7, name: 'President of The Royal Society' }
      before do
        john_smith.roles << cb
        john_smith.roles << prs
        john_smith.roles << om
        john_smith.roles << gcsi
      end
      it 'lists suffixed roles as letters in priority order' do
        expect(john_smith.letters).to eq('OM GCSI CB PRS')
      end
    end
  end

  describe '#clergy?' do
    context 'a vicar' do
      before do
        john_smith.roles << (build :vicar)
      end
      it 'is in the clergy' do
        expect(john_smith).to be_clergy
      end
    end

    context 'a farmer' do
      before do
        john_smith.roles << (build :farmer)
      end
      it 'is not in the clergy' do
        expect(john_smith).to_not be_clergy
      end
    end

    context 'a farmer who is also a vicar' do
      before do
        john_smith.roles << (build :farmer)
        john_smith.roles << (build :vicar)
      end
      it 'is in the clergy' do
        expect(john_smith).to be_clergy
      end
    end
  end

  describe '#type' do
    context 'a subject' do
      it 'is assumed to be a man' do
        expect(john_smith.type).to eq('man')
      end
    end

    context 'an actor' do
      before do
        john_smith.roles << (build :actor)
      end
      it 'is a person' do
        expect(john_smith.type).to eq('man')
      end
    end

    context 'a dog' do
      before do
        john_smith.roles << (build :dog)
      end
      it 'is an animal' do
        expect(john_smith.type).to eq('animal')
      end
    end

    context 'a dog that acts' do
      before do
        john_smith.roles << (build :dog)
        john_smith.roles << (build :actor)
      end
      it 'is an animal' do
        expect(john_smith.type).to eq('animal')
      end
    end

    context 'an actor that is a dog' do
      let(:lassie){ build :person }
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
      it 'is still alive' do
        expect(john_smith).to be_alive
      end
    end

    context 'with a date of death' do
      before do
        john_smith.died_on = Date.new(2009, 1, 1)
      end
      it 'is dead' do
        expect(john_smith).to be_dead
      end
    end

    context 'with a date of death and a date of birth' do
      before do
        john_smith.born_on = Date.new(1932, 7, 8)
        john_smith.died_on = Date.new(2009, 1, 1)
      end
      it 'is dead' do
        expect(john_smith).to be_dead
      end
    end

    context 'born within the last 110 years and no date of death' do
      before do
        john_smith.born_on = Date.new(1980, 1, 1)
      end
      it 'is alive' do
        expect(john_smith).to be_alive
      end
    end

    context 'with a date of birth before 1900' do
      before do
        john_smith.born_on = Date.new(1880, 1, 1)
      end
      it 'is dead by now' do
        expect(john_smith).to be_dead
      end
    end

    context 'a building built before 1900' do
      before do
        john_smith.born_on = Date.new(1880, 1, 1)
        john_smith.roles << (build :building)
      end
      it 'is still standing' do
        expect(john_smith).to be_alive
      end
    end
  end

  describe '#age' do
    context 'with no dates' do
      it 'has unknown age' do
        expect(john_smith.age).to eq('unknown')
      end
    end

    context 'with date of death only' do
      before do
        john_smith.died_on = Date.new(2009, 1, 1)
      end
      it 'has unknown age' do
        expect(john_smith.age).to eq('unknown')
      end
    end

    context 'born 1 March 1932 and died 4 April 2009' do
      before do
        john_smith.born_on = Date.new(1932, 3, 1)
        john_smith.died_on = Date.new(2009, 4, 4)
      end
      it 'died aged 77' do
        expect(john_smith.age).to be == '77'
      end
    end

    context 'born 14 April 1932 and died 4 April 2009' do
      before do
        john_smith.born_on = Date.new(1932, 4, 14)
        john_smith.died_on = Date.new(2009, 4, 4)
      end
      it 'died aged 77' do
        expect(john_smith.age).to be == '76'
      end
    end

    context 'born 29 April 1932 and died 4 April 2009' do
      before do
        john_smith.born_on = Date.new(1932, 4, 29)
        john_smith.died_on = Date.new(2009, 4, 4)
      end
      it 'died aged 76' do
        expect(john_smith.age).to be == '76'
      end
    end

    context 'with a date of birth and no date of death' do
      before do
        john_smith.born_on = Date.new(1980, 1, 1)
      end
      it 'has an age' do
        expect(john_smith.age).to be > 33
      end
    end

    context 'born in 1880 with no date of death' do
      before do
        john_smith.born_on = Date.new(1880, 1, 1)
      end
      it 'is of unknown age' do
        expect(john_smith.age).to eq('unknown')
      end
    end

    context 'a building built in 1880' do
      before do
        john_smith.born_on = Date.new(1880, 1, 1)
        john_smith.roles << (build :building)
      end
      it 'is over a hundred years old' do
        expect(john_smith.age).to be > 100
      end
    end
  end

  describe '#dates' do
    context 'born in 1932 and died in 2009' do
      before do
        john_smith.born_on = Date.new(1932, 7, 8)
        john_smith.died_on = Date.new(2009, 1, 1)
      end
      it 'is a year range' do
        expect(john_smith.dates).to eq('(1932-2009)')
      end
    end

    context 'with no dates' do
      it 'is nil' do
        expect(john_smith.dates).to eq(nil)
      end
    end

    context 'who died in 2009' do
      before do
        john_smith.died_on = Date.new(2009, 1, 1)
      end
        it 'is a death year' do
        expect(john_smith.dates).to eq('(d.2009)')
      end
    end

    context 'born in 1980 with no date of death' do
      before do
        john_smith.born_on = Date.new(1980, 1, 1)
      end
      it 'is a range \'([birth year]-present)\'' do
        expect(john_smith.dates).to eq('(1980-present)')
      end
    end

    context 'a building built in 1880' do
      before do
        john_smith.born_on = Date.new(1980, 1, 1)
        john_smith.roles << (build :building)
      end
      it 'is a range \'([construction year]-present)\'' do
        expect(john_smith.dates).to eq('(1980-present)')
      end
    end
  end

  describe '#accented_name?' do
    context 'with an accented name' do
      let (:bela_bartok) { build :person, name: 'Béla Bartók' }
      before do
        bela_bartok.aka_accented_name
      end
      it 'is accented' do
        expect(bela_bartok.accented_name?).to be_truthy
      end
    end

    context 'with an unaccented name' do
      before do
        john_smith.aka_accented_name
      end
      it 'is not accented' do
        expect(john_smith.accented_name?).to be_falsey
      end
    end
  end

  describe '#aka_accented_name' do
    let (:bela_bartok) { build :person, name: 'Béla Bartók' }

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
        john_smith.aka_accented_name
      end
      it 'has no aka' do
        expect(john_smith.aka).to_not include('John Smith')
      end
    end
  end

  describe '#fill_wikidata_id' do
    context 'an unfindable name' do
      let(:zdfgad) { build :person, name: 'zdfgad'}
      before do
        zdfgad.fill_wikidata_id
      end
      it 'has no Wikidata' do
        expect(zdfgad.wikidata_id).to eq(nil)
      end
    end
    context 'an ambiguous name' do
      before do
        john_smith.fill_wikidata_id
      end
      it 'has no Wikidata' do
        expect(john_smith.wikidata_id).to eq(nil)
      end
    end
    context 'an unambiguous name' do
      let(:myra_hess) { build :person, name: 'Myra Hess'}
      before do
        myra_hess.fill_wikidata_id
      end
      it 'has Wikidata' do
        expect(myra_hess.wikidata_id).to eq("Q269848")
      end
    end
  end

  describe '#wikipedia_url' do
    context 'with no wikidata id' do
      it 'has no Wikidata' do
        expect(john_smith.wikipedia_url).to eq(nil)
      end
    end
    context 'with a wikidata id' do
      before do
        john_smith.wikidata_id = "Q269848"
      end
      it 'has a wikipedia url' do
        expect(john_smith.wikipedia_url).to eq("https://en.wikipedia.org/wiki/Myra_Hess")
      end
    end
  end

  describe '#dbpedia_abstract' do
    context 'with no wikidata id' do
      it 'has no Wikidata' do
        expect(john_smith.dbpedia_abstract).to eq(nil)
      end
    end
    context 'with a wikidata id' do
      before do
        john_smith.wikidata_id = "Q2063684"
      end
      it 'has a dbpedia abstract' do
        expect(john_smith.dbpedia_abstract).to include("Matilda Alice Powles")
      end
    end
  end

end
