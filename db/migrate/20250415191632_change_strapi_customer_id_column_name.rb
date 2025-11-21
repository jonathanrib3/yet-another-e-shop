class ChangeStrapiCustomerIdColumnName < ActiveRecord::Migration[8.0]
  def change
    change_table :customers do |t|
      t.rename :strapi_customer_id, :stripe_customer_id
    end
  end
end
