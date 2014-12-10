require 'rails_helper'

RSpec.describe "Users", :type => :request do
  let (:current_user)  { $current_user = create :user }
  let (:current_access_token) {
    post "/v1/login", "username" => current_user.username, "password" => current_user.password
    $current_access_token = json['access_token']
  }

  describe "POST /v1/users" do
    it "successfully creates a new user" do
      user = attributes_for :user
      post "/v1/users", "user" => user.as_json
      expect(response).to be_success
      expect(json).to include(user.as_json(except: [:password, :password_confirmation]))
    end

    it "fails to create a new user with wrong parameters" do
      user = attributes_for :user
      user[:email] = "wrong"
      post "/v1/users", "user" => user
      expect(response).to have_http_status(422)
    end
  end


  describe "GET /v1/profile" do
    it "successfully displays own profile" do
      path = "/v1/profile"
      testOwnProfile(path)
      path = "/v1/users"
      testOwnProfile(path)
    end

    it "restricts access with wrong access token" do
      path = "/v1/profile"
      get access_token_path(path,"notatoken")
      expect(response).to_not be_success
      get path, nil, access_token_header("notatoken")
      expect(response).to_not be_success
    end
  end

  describe "PATCH/PUT /v1/profile" do
    it "successfully updates own profile" do
      user = attributes_for :user
      patch access_token_path("/v1/profile"), "user" => user.as_json
      expect(response).to be_success
      get access_token_path("/v1/profile")
      validate_profile(user)
      # passing access token via header
      patch "/v1/profile", { "user" => user.as_json }, access_token_header
      expect(response).to be_success
      get "/v1/profile", nil, access_token_header
      validate_profile(user)
    end

    it "fails to update own profile" do
      path = "/v1/profile"
      user = create :user
      patch access_token_path(path), "user" => user.as_json # username not unique
      expect(response).to have_http_status(422)
      get access_token_path(path)
      validate_profile
      # passing access token via header
      patch "/v1/profile", { "user" => user.as_json }, access_token_header # username not unique
      expect(response).to have_http_status(422)
      get "/v1/profile", nil, access_token_header
      validate_profile
      # using put
      put access_token_path("/v1/profile"), "user" => user.as_json # username not unique
      expect(response).to have_http_status(422)
      get access_token_path("/v1/profile")
      validate_profile
      # passing access token via header
      put "/v1/profile", { "user" => user.as_json }, access_token_header # username not unique
      expect(response).to have_http_status(422)
      get "/v1/profile", nil, access_token_header
      validate_profile
    end
  end

  describe "GET /v1/users/:id" do
    it "displays another users profile if the user exists" do
      user = create :user
      test_user_profile(user)
    end

    it "fails to display user profile when the user doesn't exist" do
      user = build :user
      test_fail_user_profile(user)
    end
  end

  private

  def test_user_profile(user, shouldBeValid = true)
    path = "/v1/users/" << user.id
    get access_token_path(path)
    shouldBeValid ? validate_profile(user) : invalidate_profile(user)
    get path, nil, access_token_header
    shouldBeValid ? validate_profile(user) : invalidate_profile(user)
  end

  def test_fail_user_profile(user)
    test_user_profile(user,false)
  end

  def validate_profile(user = current_user,shouldBeValid = true)
    if shouldBeValid
      expect(response).to be_success
    else
      expect(response).to_not be_success
    end
    json = convertId
    userJson = user.as_json(except: [:password, :password_confirmation, :password_digest, :access_token])
    if shouldBeValid
      expect(json).to include(userJson)
    else
      expect(json).to_not include(userJson)
    end
  end

  def invalidate_profile(user = current_user)
    validate_profile(user,false)
  end

  def convertId
    json_fixed_id = json
    if json.has_key?("_id")
      json_fixed_id["_id"] = BSON::ObjectId.from_string(json["_id"]["$oid"])
    end
    json_fixed_id
  end

  def testOwnProfile(path)
    get path,nil, access_token_header
    validate_profile
    get access_token_path(path)
    validate_profile
  end

end
