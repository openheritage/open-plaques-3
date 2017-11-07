require 'spec_helper'

describe UpcomingUnveilingsController do
  describe 'GET #show' do
    before do
      @plaque_unveiled_today = Plaque.create!(erected_at: Date.today)
      @upcoming_plaque1 = Plaque.create!(erected_at: Date.today + 340.days)
      # previously unveiled plaques
      Plaque.create(erected_at: Date.today - 1.day)
    end

    it 'should render the page' do
      get :show
      expect(response).to be_success
    end

    it 'should assign upcoming plaques' do
      get :show
      expect(assigns(:upcoming_plaques).length).to eql(2)
      expect(assigns(:upcoming_plaques)[0]).to eql(@plaque_unveiled_today)
      expect(assigns(:upcoming_plaques)[1]).to eql(@upcoming_plaque1)
    end
  end
end
