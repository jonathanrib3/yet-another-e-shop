class AddExpirationDateToConfirmationAndResetPasswordTokensOnUser < ActiveRecord::Migration[8.0]
  change_table :users, bulk: true do |t|
    t.add_column :confirmation_token_expires_at, :datetime
    t.add_column :reset_password_token_expires_at, :datetime
  end
end
