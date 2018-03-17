class AddStatusToMoneyTransfer < ActiveRecord::Migration[5.1]
  def change
    add_column :money_transfers, :status, :string, limit: 32, default: MoneyTransfer::PENDING
  end
end
