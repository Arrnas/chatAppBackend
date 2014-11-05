FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "foo#{n}" }
    password "foobar"
    password_confirmation { |u| u.password }
    sequence(:email) { |n|  "foo#{n}@example.com" }
    sequence(:deviceid) { |n|  "foo#{n}bar" }
  end
end
