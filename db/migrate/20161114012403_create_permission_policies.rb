class CreatePermissionPolicies < ActiveRecord::Migration[5.0]
  def change
    create_table :permission_policies do |t|
      t.integer :resource_id, null: false
      t.integer :role,        null: false, limit: 1, default: 0
      t.integer :ability,     null: false, limit: 1, default: 0
    end

    add_index :permission_policies, [:resource_id, :role], unique: true
  end
end
