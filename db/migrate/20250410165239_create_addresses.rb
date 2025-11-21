class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :line_1, null: false
      t.string :line_2
      t.string :zip_code, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :country, null: false
      t.integer :address_type, null: false, default: 0
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
