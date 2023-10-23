# frozen_string_literal: true

require 'rails_helper'

describe AntiFraudProcessor do
  describe 'when payload does not contain potential risk' do
    let!(:params) do
      {
        'transaction_id': 2342357,
        'merchant_id': 29744,
        'user_id': 97059,
        'card_number': '434505******9116',
        'transaction_date': '2022-12-05T13:16:32.812632',
        'transaction_amount': 11000,
        'device_id': 285475
      }
    end
    let!(:user) { User.find_or_create_by(external_id: params['user_id']) }

    it 'should approve transaction' do
      result = described_class.new(user, params).call
      expect(result).to eq({ 'transaction_id' => params[:transaction_id], 'recommendation' => 'approve' })
    end
  end

  describe 'when user has chargeback in his past transactions' do
    let!(:params) do
      {
        'transaction_id': 2342357,
        'merchant_id': 29744,
        'user_id': 97059,
        'card_number': '434505******9116',
        'transaction_date': '2022-12-05T13:16:32.812632',
        'transaction_amount': 11000,
        'device_id': 285475
      }
    end
    let!(:user) { User.find_or_create_by(external_id: params['user_id'], has_previous_chargeback: true) }

    it 'should reject transaction' do
      result = described_class.new(user, params).call
      expect(result).to eq({ 'transaction_id' => params[:transaction_id], 'recommendation' => 'reject' })
    end
  end

  describe 'when amount is higher than the usual behavior of user' do
    let!(:user) { User.find_or_create_by(external_id: 97059) }
    let!(:params) do
      {
        'transaction_id': 2342357,
        'merchant_id': 29744,
        'user_id': 97059,
        'card_number': '434505******9116',
        'transaction_date': '2022-12-05T13:16:32.812632',
        'transaction_amount': 11000,
        'device_id': 285475
      }
    end

    before do
      [251, 363, 172].each do |amount|
        params[:transaction_amount] = amount
        result = described_class.new(user, params).call
        Transaction.create(
          external_id: params[:transaction_id],
          merchant_id: params[:merchant_id],
          card_number: params[:card_number],
          date: params[:transaction_date],
          amount: params[:transaction_amount],
          rejected_by_antifraud: result['recommendation'] == 'reject',
          user: user
        )
      end
    end

    it 'should reject transaction' do
      params[:transaction_amount] = 11000
      result = described_class.new(user, params).call
      expect(result).to eq({ 'transaction_id' => params[:transaction_id], 'recommendation' => 'reject' })
    end
  end

  describe 'when amount is higher than the allowed at night' do
    let!(:params) do
      {
        'transaction_id': 2342357,
        'merchant_id': 29744,
        'user_id': 97059,
        'card_number': '434505******9116',
        'transaction_date': '2022-12-05T03:16:32.812632',
        'transaction_amount': 11_000,
        'device_id': 285475
      }
    end
    let!(:user) { User.find_or_create_by(external_id: params['user_id']) }

    it 'should reject transaction' do
      result = described_class.new(user, params).call
      expect(result).to eq({ 'transaction_id' => params[:transaction_id], 'recommendation' => 'reject' })
    end
  end

  describe 'when amount is lower than the allowed at night' do
    let!(:params) do
      {
        'transaction_id': 2342357,
        'merchant_id': 29744,
        'user_id': 97059,
        'card_number': '434505******9116',
        'transaction_date': '2022-12-05T03:16:32.812632',
        'transaction_amount': 1_000,
        'device_id': 285475
      }
    end
    let!(:user) { User.find_or_create_by(external_id: params['user_id']) }

    it 'should reject transaction' do
      result = described_class.new(user, params).call
      expect(result).to eq({ 'transaction_id' => params[:transaction_id], 'recommendation' => 'approve' })
    end
  end

  describe 'when device, card and merchant are not know in the user history' do
    let!(:params) do
      {
        'transaction_id': 2342357,
        'merchant_id': 29745,
        'user_id': 97059,
        'card_number': '434505******9117',
        'transaction_date': '2022-12-05T03:16:32.812632',
        'transaction_amount': 1_000,
        'device_id': 285476
      }
    end
    let!(:user) do
      User.create(
        external_id: params['user_id'],
        previous_cards: ['434505******9116'],
        previous_devices: [285475],
        previous_merchants: [29744])
    end

    it 'should reject transaction' do
      result = described_class.new(user, params).call
      expect(result).to eq({ 'transaction_id' => params[:transaction_id], 'recommendation' => 'reject' })
    end
  end

  describe 'when activity is too hight' do
    let!(:params) do
      {
        'transaction_id': 2342357,
        'merchant_id': 29745,
        'user_id': 97059,
        'card_number': '434505******9117',
        'transaction_date': '2022-12-05T03:16:32.812632',
        'transaction_amount': 1_000,
        'device_id': 285476
      }
    end
    let!(:user) { User.find_or_create_by(external_id: params['user_id']) }

    before do
      6.times do |i|
        Transaction.create(
          external_id: params[:transaction_id] + i,
          merchant_id: params[:merchant_id],
          card_number: params[:card_number],
          date: params[:transaction_date],
          amount: params[:transaction_amount],
          rejected_by_antifraud: false,
          user: user
        )
      end
    end

    it 'should reject transaction' do
      result = described_class.new(user, params).call
      expect(result).to eq({ 'transaction_id' => params[:transaction_id], 'recommendation' => 'reject' })
    end
  end

  describe 'when rejected activity is too hight' do
    let!(:params) do
      {
        'transaction_id': 2342357,
        'merchant_id': 29745,
        'user_id': 97059,
        'card_number': '434505******9117',
        'transaction_date': '2022-12-05T03:16:32.812632',
        'transaction_amount': 1_000,
        'device_id': 285476
      }
    end
    let!(:user) { User.find_or_create_by(external_id: params['user_id']) }

    before do
      4.times do |i|
        Transaction.create(
          external_id: params[:transaction_id] + i,
          merchant_id: params[:merchant_id],
          card_number: params[:card_number],
          date: params[:transaction_date],
          amount: params[:transaction_amount],
          rejected_by_antifraud: true,
          user: user
        )
      end
    end

    it 'should reject transaction' do
      result = described_class.new(user, params).call
      expect(result).to eq({ 'transaction_id' => params[:transaction_id], 'recommendation' => 'reject' })
    end
  end
end
