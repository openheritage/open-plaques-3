require 'spec_helper'

describe 'JSON API' do

  describe 'plaque API' do

    before do
#      user = User.create!(name: 'test test', username: 'testingtesting', password: 'testing12345', password_confirmation: 'testing12345', email: 'test@test.invalid')
      @plaque = Plaque.create!()
      get "/plaques/#{@plaque.id}.json"
    end

    it "should return 200" do
      expect(response.status).to eql(200)
    end

    it "should return application/json content-type" do
      expect(response.content_type.to_s).to eql("application/json")
    end

  end

end