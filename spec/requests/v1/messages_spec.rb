require 'rails_helper'

RSpec.describe "Messages", :type => :request do
  let (:current_user)  { $current_user = create :user }
  let (:current_access_token) {
    post "/v1/login", "username" => current_user.username, "password" => current_user.password
    $current_access_token = json['access_token']
  }

  describe "GET /v1/groups/:id/messages" do
    it "should display group messages" do
      user1 = create :user
      user2 = create :user
      group = create(:group, title: "best chat", users: [current_user,user1])
      message = create(:message, group: group, author: user1)
      get access_token_path("/v1/groups/" << group.id << "/messages")
      expect(response).to be_success
      expect(convertId).to include(message.as_json(except: :timestamp))
      get access_token_path("/v1/groups/" << group.id << "/messages",user1.access_token)
      expect(response).to be_success
      expect(convertId).to include(message.as_json(except: :timestamp))
      get access_token_path("/v1/groups/" << group.id << "/messages",user2.access_token)
      expect(response).to_not be_success
      expect(convertId).to_not include(message.as_json(except: :timestamp))
    end
  end

  describe "POST /v1/groups/:id/messages" do
    it "should create a new message" do
      group = create(:group, title: "best chat", users: [current_user])
      message = build(:message, group: group, author: current_user)
      post access_token_path("/v1/groups/" << group.id << "/messages"), "message" => message.as_json
      expect(response).to be_success
      expect(convertId).to include(message.as_json(except: [:timestamp,:_id]))
    end
  end

  describe "GET /v1/messages" do
    it "should display created message" do
      group = create(:group, title: "best chat", users: [current_user])
      message = create(:message, group: group, author: current_user)
      get access_token_path("/v1/messages/" << message.id)
      expect(response).to be_success
      expect(convertId).to include(message.as_json(except: [:timestamp]))
    end
  end

  describe "PATCH/PUT /v1/messages" do
    it "should display created message" do
      group = create(:group, title: "best chat", users: [current_user])
      message = create(:message, group: group, author: current_user)
      message2 = build :message
      put access_token_path("/v1/messages/" << message.id), "message" => message2.as_json(only: :message_body)
      expect(response).to be_success
      get access_token_path("/v1/messages/" << message.id)
      expect(response).to be_success
      expect(convertId).to include(message2.as_json(only: :message_body))
    end
  end

  describe "DELETE /v1/messages" do
    it "should display created message" do
      group = create(:group, title: "best chat", users: [current_user])
      message = create(:message, group: group, author: current_user)
      delete access_token_path("/v1/messages/" << message.id)
      expect(response).to be_success
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
    ["_id", "author_id", "group_id"].each do |attr|
      if hash.has_key?(attr)
        hash[attr] = BSON::ObjectId.from_string(hash[attr]["$oid"])
      end
    end
    hash = hash.except("timestamp")
    hash
  end
end
