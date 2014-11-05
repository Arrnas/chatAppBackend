class Group
  include Mongoid::Document
  field :title, type: String
  has_and_belongs_to_many :users, class_name: 'User', inverse_of: :groups
  has_many :messages, class_name: 'Message', inverse_of: :group
  # has_many :messages, :class_name => "Message"

end
