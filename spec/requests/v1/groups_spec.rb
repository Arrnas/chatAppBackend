require 'rails_helper'

RSpec.describe "Groups", :type => :request do
  let (:current_user)  { $current_user = create :user }
  let (:current_access_token) {
    post "/v1/login", "username" => current_user.username, "password" => current_user.password
    $current_access_token = json['access_token']
  }

  describe "GET /v1/groups" do
    it "should list all of the users' groups" do
      group1 = create(:group, users: [current_user])
      group2 = create(:group, users: [current_user])
      group3 = create(:group, users: [current_user])
      get access_token_path("/v1/groups")
      expect(response).to be_success
      expect(convertId).to include(group1.as_json,group2.as_json,group3.as_json)
    end
  end

  describe "POST /v1/groups" do
    it "should create a new group" do
      user1 = create :user
      user2 = create :user
      group = build(:group, users: [user1,user2])
      post access_token_path("/v1/groups"), "group" => group.as_json
      group.users << current_user
      expect(response).to be_success
      expect(convertId).to include(group.as_json(except:[:_id]))
    end

    # it "should fail to create new group" do
    #   user1 = create :user
    #   user2 = create :user
    #   group = build(:group, users: [user1,user2])
    #   post access_token_path("/v1/groups"), "group" => group.as_json
    #   group.users << current_user
    #   expect(response).to be_success
    #   expect(convertId).to include(group.as_json(except:[:_id]))
    # end
  end

  describe "GET /v1/groups/:id" do
    it "should display a group" do
      user1 = create :user
      user2 = create :user
      group = create(:group, users: [current_user,user1,user2])
      get access_token_path("/v1/groups")
      expect(response).to be_success
      expect(convertId).to include(group.as_json)
    end
  end

  describe "PATCH/PUT /v1/groups/:id" do
    it "should update an existing group" do
      user1 = create :user
      user2 = create :user
      group = create(:group, users: [current_user,user1,user2])
      group2 = build(:group, users: [current_user,user1,user2])
      patch access_token_path("/v1/groups/" << group.id), "group" => group2.as_json
      expect(response).to be_success
      get access_token_path("/v1/groups/" << group.id)
      expect(convertId).to include(group2.as_json(except: :_id))
    end

    it "should fail to update an existing group" do
      user1 = create :user
      user2 = create :user
      group = create(:group, users: [current_user,user1,user2])
      group2 = build(:group, users: [current_user,user1,user2])
      patch access_token_path("/v1/groups/" << "wrong_id"), "group" => group2.as_json
      expect(response).to_not be_success
    end
  end

  describe "DELETE /v1/groups/:id" do
    it "should delete self from group" do
      user1 = create :user
      user2 = create :user
      group = create(:group, users: [current_user,user1,user2])
      delete access_token_path("/v1/groups/" << group.id)
      expect(response).to be_success
      get access_token_path("/v1/groups/" << group.id, user1.access_token)
      expect(json).to_not include(current_user)
    end
  end

  private

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
    if hash.has_key?("_id")
      hash["_id"] = BSON::ObjectId.from_string(hash["_id"]["$oid"])
    end
    if hash.has_key?("user_ids")
      hash["user_ids"].map! { |user|
        user = BSON::ObjectId.from_string(user["$oid"])
      }
    end
    hash
  end
end
