class CreateJtiRegistriesTable < ActiveRecord::Migration[8.0]
  def change
    create_table :jti_registries, id: false do |t|
      t.uuid :jti, null: false, primary_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :jti_registries, :jti, unique: true

    change_table :refresh_tokens, bulk: true do |t|
      t.remove :jti, type: :string
      t.column :jti, :uuid, null: false
      t.foreign_key :jti_registries, type: :uuid, column: :jti, primary_key: :jti
    end

    change_table :black_listed_tokens, bulk: true do |t|
      t.remove :jti, type: :string
      t.column :jti, :uuid, null: false
      t.foreign_key :jti_registries, type: :uuid, column: :jti, primary_key: :jti
    end

    remove_column :black_listed_tokens, :user_id, :bigint
    remove_column :refresh_tokens, :user_id, :bigint
  end
end
