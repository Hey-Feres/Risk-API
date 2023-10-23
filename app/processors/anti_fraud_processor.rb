# frozen_string_literal: true

class AntiFraudProcessor
  attr_reader :user, :params, :uknown_device, :new_merchant, :uknown_card

  ROW_RANGE_TIME = 10.minutes
  MAX_NIGHT_AMOUNT_ALLOWED = 10_000
  NIGH_HOURS = 0..5
  MAX_QNT_OF_TRANSACTION_IN_ROW = 5
  MAX_QNT_OF_REJECTED_TRANSACTION_IN_ROW = 3

  def initialize(user, params)
    @user = user
    @params = params
    @uknown_device = false
    @new_merchant = false
    @uknown_card = false
  end

  def call
    {
      'transaction_id' => params[:transaction_id],
      'recommendation' => recommendation
    }
  end

  private

  def check_device_history
    if user.previous_devices
      @uknown_device = true unless user.previous_devices.include? params[:device_id]
    else
      user.update(previous_devices: [params[:device_id]])
    end
  end

  def check_merchant_history
    if user.previous_merchants
      @new_merchant = true unless user.previous_merchants.include? params[:merchant_id]
    else
      user.update(previous_merchants: [params[:merchant_id]])
    end
  end

  def check_card_history
    if user.previous_cards
      @uknown_card = true unless user.previous_cards.include? params[:card_number]
    else
      user.update(previous_cards: [params[:card_number]])
    end
  end

  def recommendation
    check_device_history
    check_merchant_history
    check_card_history

    if user_has_previous_chargeback || amount_too_high || new_device_merchant_and_card || transaction_activity_too_high || rejected_transaction_activity_too_high || amount_too_high_for_period
      'reject'
    else
      'approve'
    end
  end

  def amount_too_high
    avg_amount = Transaction.average_amount_for_user(user)

    return false if avg_amount.zero?

    params[:transaction_amount] > avg_amount * 2
  end

  def new_device_merchant_and_card
    uknown_device && new_merchant && uknown_card
  end

  def transaction_activity_too_high
    transactions.in_date_range(time_query_from, time_query_to).count > MAX_QNT_OF_TRANSACTION_IN_ROW
  end

  def rejected_transaction_activity_too_high
    transactions.rejected.in_date_range(time_query_from, time_query_to).count > MAX_QNT_OF_REJECTED_TRANSACTION_IN_ROW
  end

  def amount_too_high_for_period
    (NIGH_HOURS.include? transaction_date.hour) && params[:transaction_amount] > MAX_NIGHT_AMOUNT_ALLOWED
  end

  def transaction_date
    @transaction_date ||= Time.zone.parse(params[:transaction_date])
  end

  def user_has_previous_chargeback
    user.has_previous_chargeback
  end

  def transactions
    @transactions ||= user.transactions
  end

  def time_query_from
    transaction_date - (ROW_RANGE_TIME / 2.0)
  end

  def time_query_to
    transaction_date + (ROW_RANGE_TIME / 2.0)
  end
end
