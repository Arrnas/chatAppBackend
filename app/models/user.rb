class User
  include Mongoid::Document
  field :username, type: String
  field :email, type: String
  field :deviceid, type: String
end
