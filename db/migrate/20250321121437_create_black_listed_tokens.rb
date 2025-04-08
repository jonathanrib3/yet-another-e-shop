class CreateBlackListedTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :black_listed_tokens do |t|
      t.string :jti, null: false
      t.references :user, null: false, foreign_key: true
      t.datetime :exp, null: false

      t.timestamps
    end

    add_index :black_listed_tokens, :jti, unique: true
  end
end
