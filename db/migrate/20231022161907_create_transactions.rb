class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.string :external_id
      t.string :merchant_id
      t.string :card_number
      t.datetime :date
      t.float :amount
      t.references :user
      t.boolean :rejected_by_antifraud

      t.timestamps
    end
  end
end
