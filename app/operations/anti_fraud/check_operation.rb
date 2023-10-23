# frozen_string_literal: true

module AntiFraud
  class CheckOperation
    def self.call(params)
      user = User.find_or_create_by(external_id: params[:user_id])

      result = ::AntiFraudProcessor.new(user, params).call
      transaction = Transaction.create(
        external_id: params[:transaction_id],
        merchant_id: params[:merchant_id],
        card_number: params[:card_number],
        date: params[:transaction_date],
        amount: params[:transaction_amount],
        rejected_by_antifraud: result['recommendation'] == 'reject',
        user: user)

      result
    end
  end
end