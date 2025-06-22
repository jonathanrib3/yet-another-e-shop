class AddExpirationDateToConfirmationAndResetPasswordTokensOnUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :confirmation_token_expires_at, :datetime
    add_column :users, :reset_password_token_expires_at, :datetime
  end
end
