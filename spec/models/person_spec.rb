require 'spec_helper'

describe Person do
  
  describe '#full_name' do

  	context 'regular name' do
  	   before do
         @person = Person.new(name: 'Frankie')
       end
       it 'joins the title and name' do
       	 expect(@person.full_name).to eq('Frankie')
       end
    end

  	context 'a Baronet is a Sir' do
  	   before do
         @person = Person.new(name: 'Frankie')
         @role = Role.new(name: 'Baronet')
         @person.roles << @role
       end
       it 'joins the title and name' do
       	 expect(@person.full_name).to eq('Sir Frankie')
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
