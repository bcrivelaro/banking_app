FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@mail.com" }
    sequence(:name) { |n| "User #{n}" }
  end
end
