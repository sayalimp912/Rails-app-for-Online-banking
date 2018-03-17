class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  scope :for_select, -> { select(arel_table[:id], arel_table[:email]).ordered }
  scope :ordered, -> { order(arel_table[:email]) }

  class << self
    def except_user(current_user_id)
      where.not(id: current_user_id)
    end
  end

  def deduct_amount(amount_to_be_deducted)
    update_columns({ balance:  balance - amount_to_be_deducted })
  end

  def credit_amount(amount_to_be_credited)
    update_columns({ balance:  balance + amount_to_be_credited })
  end
end
