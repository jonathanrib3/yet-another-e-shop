class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true, name: "unique_emails" }
      t.string :password_digest, null: false
      t.integer :role, default: 0
      t.string :confirmation_token
      t.string :reset_password_token

      t.timestamps
    end
  end
end
