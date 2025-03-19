class AddJtiToRefreshToken < ActiveRecord::Migration[8.0]
  def change
    add_column(:refresh_tokens, :jti, :string, null: false)
    add_index(:refresh_tokens, :jti, unique: true)
  end
end
