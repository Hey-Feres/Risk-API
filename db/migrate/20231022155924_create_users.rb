class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :external_id
      t.integer :previous_devices, array: true
      t.string :previous_cards, array: true
      t.integer :previous_merchants, array: true

      t.timestamps
    end
  end
end
