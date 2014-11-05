FactoryGirl.define do
  factory :group do
    sequence(:title) { |n| "foo#{n}" }
    # association :users, :factory => :user
  end
end
