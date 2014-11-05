require 'rails_helper'

RSpec.describe "Friendships", :type => :request do
  let (:current_user)  { $current_user = create :user }
  let (:current_access_token) {
    post "/v1/login", "username" => current_user.username, "password" => current_user.password
    $current_access_token = json['access_token']
  }

  describe "GET /v1/friends" do
    it "should list all friends" do
      get access_token_path("/v1/friends")
      expect(response).to be_success
      user1 = create :user
      user2 = create :user
      friendship1 = create(:friendship, owner: user1, friend: current_user, pending: false)
      friendship2 = create(:friendship, owner: current_user, friend: user2, pending: false)
      friendship1json = renameKey(friendship1.as_json(except: [:friend_id])).stringify_keys!
      friendship2json = renameKey(friendship2.as_json(except: [:owner_id])).stringify_keys!
      get access_token_path("/v1/friends")
      expect(response).to be_success
      json = convertId
      expect(json).to include(friendship1json,friendship2json)
    end
  end

  describe "GET /v1/friends/:id" do
    it "should display friendship" do
      friendship1 = create(:friendship, friend: current_user, pending: false)
      friendship1json = friendship1.as_json
      get access_token_path("/v1/friends/" << friendship1.id)
      expectFriendships(friendship1json.stringify_keys)

      friendship2 = build(:friendship, friend: current_user, pending: false)
      friendship2json = friendship1.as_json
      get access_token_path("/v1/friends/" << friendship2.id)
      expectFriendships(friendship2json.stringify_keys,false)
    end
  end

  describe "GET /v1/pending" do
    it "should list pending friends" do
      path = "/v1/pending"
      user1 = create :user
      user2 = create :user
      friendship1 = create(:friendship, owner: user1, friend: current_user)
      friendship2 = create(:friendship, owner: current_user, friend: user2)
      friendship1json = renameKey(friendship1.as_json).stringify_keys!
      friendship2json = renameKey(friendship2.as_json).stringify_keys!
      get access_token_path(path)
      expectFriendships(friendship1json)
      get path, nil, access_token_header
      expectFriendships(friendship1json)
      get access_token_path(path,user2.access_token)
      expectFriendships(friendship2json)
      get path, nil, access_token_header(user2.access_token)
      expectFriendships(friendship2json)
    end
  end

  describe "POST /v1/friends" do
    it "should create friendships" do
      user = create :user
      friendship = build(:friendship, owner: user, friend: current_user)
      post access_token_path("/v1/friends"), "friendship" => friendship.as_json.stringify_keys
      expect(response).to_not be_success
      expect(json).to include("error")
      friendship = build(:friendship, owner: current_user, friend: user)
      post access_token_path("/v1/friends"), "friendship" => friendship.as_json.stringify_keys
      expect(response).to be_success
      expect(convertId).to include(friendship.as_json(except: :id).stringify_keys)
    end
  end

  describe "PUT/PATCH /v1/friends/:id" do
    it "should update friendships" do
      user = create :user
      friendship = create(:friendship, owner: user, friend: current_user)
      put access_token_path("/v1/friends/" << friendship.id), "friendship" => { "pending" => false }
      expect(response).to be_success
      user = create :user
      friendship = create(:friendship, owner: user, friend: current_user)
      patch access_token_path("/v1/friends/" << friendship.id), "friendship" => { "pending" => false }
      expect(response).to be_success
      user = create :user
      friendship = create(:friendship, owner: user, friend: current_user)
      patch access_token_path("/v1/friends/" << friendship.id), "friendship" => { "pending" => true }
      expect(response).to_not be_success
      expect(json).to include("error")
      user = create :user
      friendship = create(:friendship, owner: user, friend: current_user)
      put access_token_path("/v1/friends/" << "wrongid"), "friendship" => { "pending" => false }
      expect(response).to_not be_success
      expect(json).to include("error")
      user = create :user
      friendship = create(:friendship, owner: user, friend: current_user)
      patch access_token_path("/v1/friends/" << "wrongid"), "friendship" => { "pending" => false }
      expect(response).to_not be_success
      expect(json).to include("error")
    end
  end

  describe "DELETE /v1/friends/:id" do
    it "should delete existing friendships" do
      user = create :user
      friendship = create(:friendship, owner: user, friend: current_user)
      delete access_token_path("/v1/friends/" << friendship.id), "friendship" => friendship.as_json(except: [:pending,:owner,:friend]).stringify_keys
      expect(response).to be_success
      delete access_token_path("/v1/friends/" << "wrongid"), "friendship" => friendship.as_json(except: [:pending,:owner,:friend]).stringify_keys
      expect(response).to_not be_success
    end
  end

  private

  def expectFriendships(friendshipJson,shouldBeValid = true)
    if shouldBeValid
      expect(response).to be_success
    else
      expect(response).to_not be_success
    end
    json = convertId
    if shouldBeValid
      expect(json).to include(friendshipJson)
    else
      expect(json).to_not include(friendshipJson)
    end
  end

  def renameKey(json)
    [:owner_id].each do |attr|
      if json.has_key?(attr)
        json[:friend_id] = json[attr]
        json = json.except(attr)
      end
    end
    json
  end

  def convertId
    jsonDup = json.dup
    if jsonDup.kind_of?(Array)
      jsonDup.map! { |hash|
        hash = convertHash(hash)
      }
    else
      jsonDup = convertHash(jsonDup)
    end
    jsonDup
  end

  def convertHash(hash)
    ["id", "friend_id", "owner_id"].each do |attr|
      if hash.has_key?(attr)
        hash[attr] = BSON::ObjectId.from_string(hash[attr]["$oid"])
      end
    end
    hash
  end
end
