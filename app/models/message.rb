class Message
  include Mongoid::Document
  field :message_body, type: String
  field :timestamp, type: Time
  belongs_to :group, class_name: 'Group', inverse_of: :messages
  belongs_to :author, class_name: 'User', inverse_of: :messages
end
