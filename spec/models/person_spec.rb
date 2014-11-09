require 'spec_helper'

describe Person do
  
  describe '#full_name' do

  	context 'regular name' do
  	   before do
         @frankie = Person.new(name: 'frankie')
       end
       it 'joins the title and name' do
       	 expect(@frankie.full_name).to eq('frankie')
       end
    end
  end

end
