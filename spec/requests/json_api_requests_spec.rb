require 'spec_helper'

describe 'JSON API' do
  describe 'plaque API' do
    before do
      @plaque = Plaque.create!
      get "/plaques/#{@plaque.id}.json"
    end

    it 'should return 200' do
      expect(response.status).to eql(200)
    end

    it 'should return application/json content-type' do
      expect(response.content_type.to_s).to eql('application/json')
    end
  end
end
