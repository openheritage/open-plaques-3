require 'spec_helper'

describe OrganisationsController do
  describe 'GET #index' do
#    let (:organisation) { create :organisation }
#    it "assigns @organisations" do
#      get :index
#      expect(assigns(:organisations)).to eq([organisation])
#    end
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe 'GET #show' do
    let (:organisation) { create :organisation }
    it 'should render the page' do
      get :show, id: organisation.name
      expect(response).to be_success
    end
  end

  describe '#new' do
  end

  describe '#create' do
  end

  describe '#update' do
  end
end
