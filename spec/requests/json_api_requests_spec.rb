require 'rails_helper'

describe 'JSON API' do
  describe 'plaque API' do
    let(:plaque) { create(:plaque) }

    before do
      get "/plaques/#{plaque.id}.json"
    end

    it 'should return 200' do
      expect(response.status).to eql(200)
    end

    it 'should return application/json content-type' do
      expect(response.media_type).to eql('application/json')
    end
  end
end
