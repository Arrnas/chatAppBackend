class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "invalid email")
    end
  end
end
class User
  include Mongoid::Document
  include ActiveModel::SecurePassword
  before_create :generate_access_token

  validates_presence_of :password, :on => :create
  validates :username, :deviceid, presence: true, uniqueness: true
  validates :email, presence: true, email: true

  field :username, type: String
  field :password_digest, type: String
  field :email, type: String
  field :deviceid, type: String
  field :access_token, type: String

  has_secure_password
  has_many :friendships, inverse_of: :owner
  has_many :messages, class_name: 'Message', inverse_of: :author
  has_and_belongs_to_many :groups, class_name: 'Group', inverse_of: :users

  index({ username: 1, deviceid: 1}, { unique: true })

  def as_json(options={})
    options[:except] ||= [:password_digest, :access_token]
    super(options)
  end

  def self.find_by_username(username)
    where(:username => username).first
  end

  def self.find_by_access_token(token)
    where(:access_token => token).first
  end

  def friends
    friends_owner = Friendship.where(:owner => self, :pending => false).without(:owner_id)
    friends_friend = Friendship.where(:friend => self, :pending => false).without(:friend_id)
    friends_owner | friends_friend
  end

  def friends_pending
    friends_friend = Friendship.where(:friend => self, :pending => true).without(:friend_id)
    friends_friend
  end

  def find_friendship(id)
    friend_owner = Friendship.where(:owner => self, :id => id)
    friend_friend = Friendship.where(:friend => self, :id => id)
    friend_owner | friend_friend
  end

  def find_pending_friendship(id)
    friend_friend = Friendship.where(:friend => self, :id => id, :pending => true)
    friend_friend
  end
  
  def get_groups
    Group.where(:user_ids => self)
  end

  def get_group_by_id(id)
    group = Group.where(:user_ids => self, :id => id).first
  end

  private

  def generate_access_token
    begin
    self.access_token = SecureRandom.hex
    end while self.class.where(access_token: access_token).exists?
  end
end
