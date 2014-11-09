require 'spec_helper'

describe Person do
  
  describe '#full_name' do

  	context 'regular name' do
  	   before do
         @frankie = Person.new(name: 'Frankie')
       end
       it 'joins the title and name' do
       	 expect(@frankie.full_name).to eq('Frankie')
       end
    end

  	context 'titled person' do
  	   before do
         @frankie = Person.new(name: 'Frankie')
         @confers_title = Role.new(name: 'Baronet', abbreviation: 'Bt')
         @frankie.roles << @confers_title
       end
       it 'joins the title and name' do
       	 expect(@frankie.full_name).to eq('Sir Frankie')
       end
    end

  end

end
