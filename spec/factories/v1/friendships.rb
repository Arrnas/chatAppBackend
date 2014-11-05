FactoryGirl.define do
  factory :friendship do
    pending true
    association :owner, :factory => :user
    association :friend, :factory => :user
  end
end
