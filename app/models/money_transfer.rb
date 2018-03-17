class MoneyTransfer < ApplicationRecord
  # associations
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  # validations
  validates :sender_id, :receiver_id, :amount, :presence => true

  PENDING    = 'Pending'
  COMPLETED  = 'Completed'

  class << self
    def between_users(current_user_id, user_id)
      where("(sender_id = (?) AND receiver_id = (?)) OR (sender_id = (?) AND receiver_id = (?))", current_user_id, user_id, user_id, current_user_id)
    end
  end
end
