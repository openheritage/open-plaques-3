require 'spec_helper'

describe PeopleController do
  

  describe "#show" do

    before do
      @jez = Person.create(name: 'Jez Nicholson')
    end

    it "should render the page" do
      get :show, id: @jez.id
      expect(response).to be_success
    end


  end


end
