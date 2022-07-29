# frozen_string_literal: true

class TransfersController < ApplicationController
  before_action :authenticate_user!

  def new; end

  def create
    @service = TransferService.new(from_account: current_account,
                                   to_account_number: params[:to_account_number],
                                   amount: params[:amount])

    if @service.valid?
      @service.save
      redirect_to transactions_path, notice: 'Transfer successfully created!'
    else
      render :new
    end
  end
end
