require 'spec_helper'

describe OrganisationsController do
  
  describe "#index" do
  end

  describe "#show" do
    before do
      @organisation = Organisation.create(name: 'xxx')
    end

    it "should render the page" do
      get :show, id: @organisation.name
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
