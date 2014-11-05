require 'rails_helper'

RSpec.describe User, :type => :model do
  it "should authenticate with matching username and password" do
    user = create(:user, :username => 'test123', :password => 'secret')
    User.find_by_username('test123').authenticate('secret') == user
  end

  [:username, :deviceid, :password, :email].each do |attr|
    it "#{attr} is required" do
      u = build(:user, attr => "")
      expect(u).to_not be_valid
    end
  end

  [:username, :deviceid].each do |attr|
    it "#{attr} should be unique" do
      create(:user, attr => "test")
      u = build(:user, attr => "")
      expect(u).to_not be_valid
    end
  end

  it "should generate an access_token" do
    u = create(:user)
    expect(u.access_token).to_not be_nil
  end

  it "should confirm valid password_confirmation" do
    u = create(:user, :password => "testpass", :password_confirmation => "testpass")
    expect(u).to be_valid
  end

  it "should not allow invalid password_confirmation" do
    u = build(:user, :password => "testpass", :password_confirmation => "wrongpass")
    expect(u).to_not be_valid
  end

  it "should not display password_digest and access_token in default json" do
    u = create :user
    expect(u.as_json).to_not include("password_digest", "access_token")
  end

  it "should display username,email and deviceid in default json" do
    u = create :user
    expect(u.as_json).to include("username","email","deviceid","_id")
  end

  it "should not allow invalid email" do
    expect(build(:user, :email => "not_an_email@fail")).to_not be_valid
  end

  it "should find a user by his access token" do
    u1 = create :user
    expect(User.find_by_access_token(u1.access_token)).to eq u1
  end

  it "should show valid friendships" do
    u1 = create :user
    u2 = create :user
    u3 = create :user
    f1 = u1.friendships.new(friend: u2, pending: false)
    f2 = u3.friendships.new(friend: u1, pending: false)
    f1.save
    f2.save
    expect(u1.friends).to include(f2,f1)
  end
  it "should show valid pending friendships" do
    u1 = create :user
    u2 = create :user
    u3 = create :user
    f1 = u2.friendships.new(friend: u1)
    f2 = u3.friendships.new(friend: u1)
    f1.save
    f2.save
    expect(u1.friends_pending).to include(f1,f2)
  end
  it "should find pending friendships" do
    u1 = create :user
    u2 = create :user
    f1 = u2.friendships.new(friend: u1)
    f1.save
    expect(u1.find_pending_friendship(f1)).to include(f1)
  end
  it "should show find friendships" do
    u1 = create :user
    u2 = create :user
    f1 = u2.friendships.new(friend: u1)
    f1.save
    expect(u1.find_friendship(f1)).to include(f1)
    expect(u2.find_friendship(f1)).to include(f1)
  end
end
