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


  describe "#index" do

    it "should redirect to the 'a' page" do
      get :index
      expect(response).to redirect_to(people_by_index_path('a'))
    end

  end


end
