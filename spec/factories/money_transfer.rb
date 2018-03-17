FactoryGirl.define do
  factory :money_transfer do
    sender_id { 1 }
    receiver_id { 2 }
    amount { 50.0 }
  end
end
