class CreatePermissionResources < ActiveRecord::Migration[5.0]
  def change
    create_table :permission_resources do |t|
      t.string :name,       null: false
      t.string :class_name, null: false
      t.string :action,     null: false
    end

    add_index :permission_resources, [:name, :class_name, :action], unique: true
  end
end
