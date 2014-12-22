require 'spec_helper'

describe Person do
  
  describe '#full_name' do

  	context 'a regular name' do
  	    before do
          @person = Person.new(name: 'John Smith')
       end
        it 'is just shown in full' do
       	  expect(@person.full_name).to eq('John Smith')
        end
        it 'uses the last word in the name to index on' do
          @person.update_index
          expect(@person.surname_starts_with).to eq('s')
        end
    end

  	context 'a Baronet' do
  	   before do
         @person = Person.new(name: 'John Smith')
         @person.roles << Role.new(name: 'Baronet')
       end
       it 'is referred to as a Sir' do
       	 expect(@person.full_name).to eq('Sir John Smith')
       end
    end

    context 'a vicar' do
       before do
         @person = Person.new(name: 'Malcolm McBonny')
         @person.roles << Role.new(name: 'Vicar', role_type: 'clergy', abbreviation: 'Revd')
       end
       it 'is a clergyman' do
          expect(@person.clergy?).to eq(true)
       end
       it 'is a Reverend' do
          expect(@person.title).to eq('Revd')
       end
    end

    context 'a vicar who is titled' do
       before do
         @person = Person.new(name: 'Malcolm McBonny')
         @person.roles << Role.new(name: 'Vicar', role_type: 'clergy', abbreviation: 'Revd')
         @person.roles << Role.new(name: 'Baronet')
       end
       it 'does not get called Sir' do
          expect(@person.full_name).to eq('Revd Malcolm McBonny')
       end
    end

#    context 'a member of the Commonwealth' do
#       before do
#         @person = Person.new(name: 'Malcolm McBonny')
#         @person.roles << Role.new(name: 'Baronet')
#         @person.roles << Role.new(name: 'Member of the Commonwealth')  ??
#       end
#       it 'does not get called Sir' do
#         expect(@person.full_name).to eq('Malcolm McBonny')
#       end
#    end

    context 'a title role' do
       before do
         @person = Person.new(name: 'Harry Bean')
         @role = Role.new(name: 'Smiter', role_type: 'title')
         @person.roles << @role
       end
       it 'says the title before the name' do
         expect(@person.full_name).to eq('Smiter Harry Bean')
       end
    end

    context 'a title with an abbreviation' do
       before do
         @person = Person.new(name: 'Harry Bean')
         @role = Role.new(name: 'Smiter', abbreviation: 'Smt', role_type: 'title')
         @person.roles << @role
       end
       it 'says the abbreviation before the name' do
         expect(@person.full_name).to eq('Smt Harry Bean')
       end
    end

    context 'two different titles confering the same prefix' do
       before do
         @person = Person.new(name: 'Harry Bean')
         @role = Role.new(name: 'Smiter', abbreviation: 'Smt', role_type: 'title')
         @person.roles << @role
         @role2 = Role.new(name: 'Wolverine', abbreviation: 'Smt', role_type: 'title')
         @person.roles << @role2
       end
       it 'only say the title once before the name' do
         expect(@person.full_name).to eq('Smt Harry Bean')
       end
    end
  	context 'with qualifications' do
  	   before do
         @person = Person.new(name: 'John Smith')
         @role = Role.new(name: 'Toodle', abbreviation: 'Td', role_type: 'letters')
         @person.roles << @role
       end
       it 'puts letters after the name' do
       	 expect(@person.full_name).to eq('John Smith Td')
       end
    end
 
  	context 'multiple qualifications' do
  	   before do
         @person = Person.new(name: 'John Smith')
         @role = Role.new(name: 'Toodle', abbreviation: 'Td', role_type: 'letters')
         @person.roles << @role
         @role = Role.new(name: 'Pip', abbreviation: 'P', role_type: 'letters')
         @person.roles << @role
       end
       it 'puts multiple letters after the name' do
       	 expect(@person.full_name).to eq('John Smith Td P')
       end
    end
 
  	context 'old roles' do
  	   before do
         @victoria = Person.new(name: 'Victoria')
         @queen = Role.new(name: 'Queen of the United Kingdom', abbreviation: 'Queen', role_type: 'title')
         @victoria.roles << @queen
         @victoria_is_a_queen = @victoria.personal_roles.first
         @princess = Role.new(name: 'Princess', abbreviation: 'Princess', role_type: 'title')
         @victoria.roles << @princess
         @victoria_is_a_princess = @victoria.personal_roles.last
         @victoria_is_a_princess.ended_at = "1902-01-01"
       end
       it 'only puts current titles before the name' do
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

end
