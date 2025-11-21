class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone_number, null: false
      t.string :document_number, null: false, index: { unique: true }
      t.integer :document_type, null: false
      t.date :date_of_birth, null: false
      t.string :strapi_customer_id, index: { unique: true }
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
