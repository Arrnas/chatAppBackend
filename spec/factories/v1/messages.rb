FactoryGirl.define do
  factory :message do
    sequence(:message_body) { |n| "foo#{n}" }
    timestamp DateTime.now
    # association :users, :factory => :user
  end
end
