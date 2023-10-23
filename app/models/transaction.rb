# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :user

  scope :accepted, -> {
    where(rejected_by_antifraud: false)
  }

  scope :rejected, -> {
    where(rejected_by_antifraud: true)
  }

  scope :in_date_range, ->(start_time, end_time) {
    where(date: start_time..end_time)
  }

  scope :average_amount_for_user, ->(user) {
    accepted.where(user: user).average(:amount) || 0
  }
end
