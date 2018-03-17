require 'rails_helper'

describe User do
  describe ".except_user(current_user_id)" do
    let!(:user1) { create(:user, { email: 'john.doe@example.com', balance: 100.0 }) }
    let!(:user2) { create(:user, { email: 'jane.doe@example.com', balance: 200.0 }) }

    subject { User.except_user(user1.id) }

    it "should return all users except user1" do
      expect(subject).to include user2
      expect(subject).to_not include user1
    end
  end

  describe ".deduct_amount(amount_to_be_deducted)" do
    let!(:user1) { create(:user, { email: 'john.doe@example.com', balance: 100.0 }) }
    let!(:user2) { create(:user, { email: 'jane.doe@example.com', balance: 200.0 }) }
    let!(:money_transfer1) { create(:money_transfer, { sender_id: user2.id, receiver_id: user1.id, amount: 100.0 }) }

    subject { user2.deduct_amount(money_transfer1.amount) }

    it "should deduct transfer amount from sender's balance" do
      subject
      expect(User.find(user2.id).balance).to eq 100.0
    end
  end

  describe "credit_amount(amount_to_be_credited)" do
    let!(:user1) { create(:user, { email: 'john.doe@example.com', balance: 100.0 }) }
    let!(:user2) { create(:user, { email: 'jane.doe@example.com', balance: 200.0 }) }
    let!(:money_transfer1) { create(:money_transfer, { sender_id: user2.id, receiver_id: user1.id, amount: 100.0 }) }

    subject { user1.credit_amount(money_transfer1.amount) }

    it "should credit transfer amount to receiver's balance" do
      subject
      expect(User.find(user1.id).balance).to eq 200.0
    end
  end
end