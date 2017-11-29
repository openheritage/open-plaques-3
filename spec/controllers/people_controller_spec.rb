require 'spec_helper'

describe PeopleController do
  describe 'GET #index' do
    it 'should redirect to the A page' do
      get :index
      expect(response).to redirect_to(people_by_index_path('a'))
    end
  end

  describe 'GET #show' do
    it 'should render the page' do
      @jez = Person.create(name: 'Jez Nicholson')
      get :show, params: { id: @jez.id }, format: :html
      expect(response).to render_template(:show)
    end
    it 'should render the page' do
      @jez = Person.create(name: 'Jez Nicholson')
      get :show, params: { id: @jez.id }, format: :json
      expect(response.content_type).to eq 'application/json'
    end
  end
end
