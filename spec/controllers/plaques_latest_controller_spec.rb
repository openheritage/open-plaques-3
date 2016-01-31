require 'spec_helper'

describe PlaquesLatestController do
  
  describe "#show" do

    context 'json' do 
      before { get :show, format: :json }
      
      it 'should render 200' do
        expect(response).to be_success
      end
    end

  end

end
