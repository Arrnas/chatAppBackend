class FriendshipValidator < ActiveModel::Validator
  def validate(record)
    if record.friend.nil?
      record.errors[:error] << "Parameter 'friend_id' is required!"
      return
    end
    if record.owner.nil?
      record.errors[:error] << "Parameter 'owner_id' is required!"
      return
    end
    if record.owner == record.friend
      record.errors[:error] << "You can't be your own friend!"
      return
    end
    owners_friend = Friendship.where(:owner => record.owner, :friend => record.friend)
    friends_friend = Friendship.where(:owner => record.friend, :friend => record.owner)
    if owners_friend.any? || friends_friend.any?
      record.errors[:error] << "Such a friendship already exists!"
      return
    end
  end
end
class PendingValidator < ActiveModel::Validator
  def validate(record)
    if record.pending == true
      record.errors[:error] << "Parameter 'pending' can't be set to true!" # kad galetu failint update....
      return
    end
  end
end
class Friendship
  include Mongoid::Document
  belongs_to :owner, :class_name => "User"
  belongs_to :friend, :class_name => "User"
  field :pending, type: Mongoid::Boolean, :default => true

  validates_with FriendshipValidator, on: :create
  validates_with PendingValidator, on: :update

  def as_json(options={})
    json = { :id => _id }
    if owner && friend
      json.merge!({ :owner_id => owner_id, :friend_id => friend_id })
    elsif owner
      json.merge!({ :friend_id => owner_id })
    else
      json.merge!({ :friend_id => friend_id })
    end
    json.merge!(:pending => pending)
    if options[:except]
      if options[:except].kind_of?(Array)
        options[:except].each do |exception|
          json = json.except(exception)
        end
      elsif options[:except].kind_of?(Symbol)
        json = json.except(options[:except])
      end
    end
    json
  end
end
