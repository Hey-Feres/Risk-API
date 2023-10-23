class AddHasPreviousChargebackToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :has_previous_chargeback, :boolean, default: false
  end
end
