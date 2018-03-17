require 'rails_helper'
require 'devise'

describe MoneyTransfersController do
  include ActionView::RecordIdentifier
  render_views

  context "with authorized access" do
    let!(:current_user) { create(:user, { email: 'john.doe@example.com', balance: 100.0 }) }
    let!(:other_user) { create(:user, { email: 'jane.doe@example.com', balance: 200.0 }) }
    before {
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      sign_in user
      allow(controller).to receive(:current_user).and_return(current_user)
    }

    describe "GET /money_transfers" do
      let!(:money_transfer1) { create(:money_transfer, { sender_id: other_user.id, receiver_id: current_user.id, amount: 100.0 }) }
      before { get :index }

      it { should respond_with(:success) }
      it { should render_template(:index) }

      it "should render template information" do
        assert_select('td', { :text => current_user.email, :count => 1 })
        assert_select('td', { :text => other_user.email, :count => 1 })
        assert_select('tr', { :count => 2 })
      end

      it "should render a link to all users" do
        assert_select('a', { :href => users_path })
      end
    end

    describe "GET /money_transfers/new" do
      before { get :new }
      it { should respond_with(:success) }
      it { should render_template(:new) }

      it "should render new form" do
        assert_select('form[method=post][action=?]', money_transfers_path)
        assert_select('select[name=?]', 'money_transfer[receiver_id]')
        assert_select('input[type=text][name=?]', 'money_transfer[amount]')
        assert_select('input[type=submit]')
      end
    end

    describe "POST /money_transfers" do
      context "with invalid attributes" do
        before { post :create, params: { :money_transfer => attributes_for(:money_transfer, sender_id: current_user.id,  receiver_id: '', amount: '') } }
        it { should respond_with(:success) }
        it { should render_template(:new) }

        it "should render error messages" do
          assert_select('#error_explanation')
        end
      end

      context "with valid attributes" do
        before { post :create, params: { :money_transfer => attributes_for(:money_transfer, sender_id: other_user.id, receiver_id: current_user.id, amount: 100.0) } }
        it { should respond_with(:redirect) }

        it "should create new entry in the database" do
          expect(MoneyTransfer.count).to eq 1
          expect(MoneyTransfer.last.sender.email).to eq other_user.email
          expect(MoneyTransfer.last.receiver.email).to eq current_user.email
          expect(MoneyTransfer.last.amount).to eq 100.0
        end
      end
    end

    describe "PUT /money_transfers/1" do
      context "with valid attributes and transaction" do
        let!(:money_transfer1) { create(:money_transfer, { sender_id: other_user.id, receiver_id: current_user.id, amount: 10.0, status: MoneyTransfer::PENDING }) }
        before { put :update, params: { :id => money_transfer1.id } }

        it "should update entry in the database" do
          expect(MoneyTransfer.find(money_transfer1.id).status).to eq MoneyTransfer::COMPLETED
        end

        it "should deduct transfer amount from sender's balance"  do
          expect(User.find(other_user.id).balance).to eq 190.0
        end

        it "should credit transfer amount to receiver's balance" do
          expect(User.find(current_user.id).balance).to eq 110.0
        end
      end

      context "with valid attributes and invalid transaction" do
        let!(:money_transfer1) { create(:money_transfer, { sender_id: other_user.id, receiver_id: current_user.id, amount: 1000.0, status: MoneyTransfer::PENDING }) }
        before { put :update, params: { :id => money_transfer1.id }, format: 'json' }

        it "should not update entry in the database" do
          expect(MoneyTransfer.find(money_transfer1.id).status).to eq MoneyTransfer::PENDING
        end

        it "should not deduct transfer amount from sender's balance"  do
          expect(User.find(other_user.id).balance).to eq 200.0
        end

        it "should not credit transfer amount to receiver's balance" do
          expect(User.find(current_user.id).balance).to eq 100.0
        end

        it "should return error message" do
          data = JSON.parse(response.body)
          expect(data['status']).to eq 'error'
          expect(data['error']).to eq  'Failed to transfer money, since the sender does not have enough money at the moment.'
        end
      end
    end

  end

  context "without authorized access" do
    describe "GET, POST, PUT, DELETE" do
      it "should redirect to root" do
        get :index
        should redirect_to(new_user_session_path)

        post :create
        should redirect_to(new_user_session_path)

        get :update, params: { :id => 1 }
        should redirect_to(new_user_session_path)
      end
    end
  end
end
