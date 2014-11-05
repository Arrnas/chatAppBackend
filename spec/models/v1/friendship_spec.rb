require 'rails_helper'

RSpec.describe Friendship, :type => :model do

  [:owner, :friend].each do |attr|
    it "#{attr} is required" do
      u = build(:friendship, attr => "")
      expect(u).to_not be_valid
    end
  end

  it "shouldn't allow duplicate friendships" do
    u1 = create :user
    u2 = create :user
    f1 = create(:friendship, owner: u1, friend: u2)
    f2 = build(:friendship, owner: u2, friend: u1)
    expect(f2).to_not be_valid
  end

  it "shouldn't allow self frienship" do
    u1 = create :user
    f1 = build(:friendship, owner: u1, friend: u1)
    expect(f1).to_not be_valid
  end
end
