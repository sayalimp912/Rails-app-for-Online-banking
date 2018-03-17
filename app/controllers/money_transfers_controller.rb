class MoneyTransfersController < ApplicationController
  respond_to :html, :json

  before_action :authenticate_user!
  before_action :set_user_dropdown, only: [:new, :create]

  def index
    @money_transfers = MoneyTransfer.all
  end

  def new
    @money_transfer = MoneyTransfer.new
  end

  def update
    @money_transfer = MoneyTransfer.find(params[:id])
    ActiveRecord::Base.transaction do
      if @money_transfer.sender.balance >= @money_transfer.amount
        @money_transfer.sender.deduct_amount(@money_transfer.amount)
        @money_transfer.receiver.credit_amount(@money_transfer.amount)
        @money_transfer.update({ status: MoneyTransfer::COMPLETED })
        render :json => { success: "Transaction Completed.", transfer_id: @money_transfer.id }
      else
        render :json => { status: 'error', error: "Failed to transfer money, since the sender does not have enough money at the moment." }
      end
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
    render :json => { error: "Failed to transfer money." }
  end

  def create
    @money_transfer = MoneyTransfer.new(money_transfer_params)

    respond_to do |format|
      if @money_transfer.save
        format.html { redirect_to money_transfers_path, :notice => "Money Transfer Initiated." }
      else
        format.html { render action: 'new' }
      end
    end
  end

  protected

  def set_user_dropdown
    @users = User.except_user(current_user.id).for_select
  end

  def money_transfer_params
    params.require(:money_transfer).permit([:sender_id, :receiver_id, :amount])
  end
end
