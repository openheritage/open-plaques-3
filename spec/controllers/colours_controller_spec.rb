require 'spec_helper'

describe ColoursController do
  
  describe "#index" do
  end

  describe "#show" do
    before do
      @colour = Colour.create(name: 'xxx')
    end

    it "should render the page" do
      get :show, id: @colour.name
      expect(response).to be_success
    end

    it "should render the page" do
      get :show, id: @colour.id
      expect(response).to be_success
    end
  end
  
  describe "#new" do
  end
  
  describe "#create" do
  end
  
  describe "#update" do
  end

end
