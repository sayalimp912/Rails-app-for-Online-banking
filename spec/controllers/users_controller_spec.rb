require 'rails_helper'

describe UsersController do
  include ActionView::RecordIdentifier
  render_views

  context "with authorized access" do
    let!(:user1) { create(:user, { email: 'john.doe@example.com', balance: 100.0 }) }
    let!(:user2) { create(:user, { email: 'jane.doe@example.com', balance: 200.0 }) }
    let!(:user3) { create(:user, { email: 'shane.doe@example.com', balance: 500.0 }) }
    let!(:money_transfer1) { create(:money_transfer, { sender_id: user2.id, receiver_id: user1.id, amount: 100.0 }) }
    let!(:money_transfer2) { create(:money_transfer, { sender_id: user3.id, receiver_id: user1.id, amount: 100.0 }) }

    describe "GET /users" do
      before { get :index }

      it { should respond_with(:success) }
      it { should render_template(:index) }

      it "should render template information" do
        assert_select('td', { :text => user1.email, :count => 1 })
        assert_select('td', { :text => user2.email, :count => 1 })
        assert_select('td', { :text => user3.email, :count => 1 })
      end

      it "should render a link to all transfers" do
        assert_select('a', { :href => money_transfers_path })
      end
    end

    describe "GET /users/1" do
      context "with user other than current_user" do
        before do
          allow(controller).to receive(:current_user).and_return(user2)
          get :show, params: { :id => user1.id }
        end

        it { should respond_with(:success) }
        it { should render_template(:show) }

        it "should display user's email" do
          assert_select('div', { :text => user1.email })
        end

        it "should render a link to users index page" do
          assert_select('a', { :href => users_path })
        end

        it "should list transactions between current user2(current_user) and user1" do
          assert_select('tr', {:count => 2 }) # includes header and one money transfer record.
          assert_select('td', { :text => user1.email, :count => 1 })
          assert_select('td', { :text => user2.email, :count => 1 })
        end
      end
      context "with user as current_user" do
        before do
          allow(controller).to receive(:current_user).and_return(user2)
          get :show, params: { :id => user2.id }
        end

        it { should respond_with(:success) }
        it { should render_template(:show) }

        it "should display user's email" do
          assert_select('div', { :text => user2.email })
        end

        it "should render a link to users index page" do
          assert_select('a', { :href => users_path })
        end

        it "should show user's balance" do
          assert_select('label', { :text => 'Balance' })
          assert_select('div', { :text => user2.balance.to_s })
        end
      end
    end

    describe "GET /users/1/edit" do
      before { get :edit, params: { :id => user1.id } }
      it { should respond_with(:success) }
      it { should render_template(:edit) }

      it "should render a link to all users" do
        assert_select('a', { :href => users_path })
      end

      it "should render edit form" do
        assert_select('input[name=?]', 'user[email]')
        assert_select('input[type=submit]')
      end
    end
  end
end
