require 'rails_helper'

describe MoneyTransfer do
  # Associations
  it { should belong_to :sender }
  it { should belong_to :receiver }

  # Validations
  it { should validate_presence_of :sender_id }
  it { should validate_presence_of :receiver_id }
  it { should validate_presence_of :amount }

  describe ".between_users(current_user_id, user_id)" do
    let!(:user1) { create(:user, { email: 'john.doe@example.com', balance: 100.0 }) }
    let!(:user2) { create(:user, { email: 'jane.doe@example.com', balance: 200.0 }) }
    let!(:user3) { create(:user, { email: 'shane.doe@example.com', balance: 500.0 }) }
    let!(:money_transfer1) { create(:money_transfer, { sender_id: user2.id, receiver_id: user1.id, amount: 100.0 }) }
    let!(:money_transfer2) { create(:money_transfer, { sender_id: user3.id, receiver_id: user1.id, amount: 100.0 }) }

    subject { MoneyTransfer.between_users(user1.id, user2.id) }

    it "should return transfers between user1 and user2" do
      expect(subject).to include(money_transfer1)
      expect(subject).to_not include(money_transfer2)
    end
  end
end