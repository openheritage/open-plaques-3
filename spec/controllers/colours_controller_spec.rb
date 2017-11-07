require 'spec_helper'

describe ColoursController do
  describe '#index' do
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe '#new' do
  end

  describe '#create' do
  end

  describe '#update' do
  end
end
