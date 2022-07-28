# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @transactions = current_account.transactions.includes(:from_account, :to_account)
  end
end
