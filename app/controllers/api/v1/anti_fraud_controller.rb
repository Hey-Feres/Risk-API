# frozen_string_literal: true

class Api::V1::AntiFraudController < ApplicationController
  def check
    result = ::AntiFraud::CheckOperation.call(transaction_params)
    render json: result
  end

  private

  def transaction_params
    params.permit(:transaction_id, :merchant_id, :user_id, :card_number, :transaction_date, :transaction_amount, :device_id)
  end
end
