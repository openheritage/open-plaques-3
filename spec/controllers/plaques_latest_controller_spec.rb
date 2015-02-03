require 'spec_helper'

describe PlaquesLatestController do
  

  describe "#show" do
      
    context 'html' do 
      before { get :show }
      
      it 'should render 200' do
        expect(response).to be_success
      end
    end


  end

end
