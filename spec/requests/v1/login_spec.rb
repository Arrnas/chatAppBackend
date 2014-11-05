require 'rails_helper'

RSpec.describe "Login", :type => :request do
  describe "POST /v1/login" do
    it "returns an access token when passed correct credentials" do
      u1 = create :user
      post "/v1/login", "username" => u1.username, "password" => u1.password
      expect(response).to be_success
      expect(json['access_token'])
    end

    it "fails when passed incorrect credentials" do
      post "/v1/login", "username" => "wrong", "password" => "password"
      expect(response).to have_http_status(401)
      expect(json['access_token']).to be_nil
    end
  end
end
