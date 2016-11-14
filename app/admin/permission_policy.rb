ActiveAdmin.register Permission::Policy do
  actions :index

  filter :ability,                    as: :select, collection: controller.resource_class.abilities
  filter :resource_name_equals,       as: :select, collection: -> { Permission::Resource.distinct.pluck(:name).sort }
  filter :resource_class_name_equals, as: :select, collection: -> { Permission::Resource.distinct.pluck(:class_name).sort }

  scope(:all, default: true)

  controller.resource_class.configurable_roles.each_key(&method(:scope))

  controller.resource_class.abilities.each_key do |ability|
    batch_action ability do |ids|
      resource_class.where(id: ids).update_all(ability: resource_class.abilities[ability])
      redirect_to :back, notice: "selected records have changed to #{ability}"
    end
  end

  collection_action :reload, method: :post do
    Permission::Resource.reload
    redirect_to :back, notice: "reloaded"
  end

  action_item :reload do
    link_to "reload", reload_admin_permission_policies_path, method: :post
  end

  controller do
    protected

    def scoped_collection
      super.includes(:resource)
    end
  end

  index do
    selectable_column
    column :role
    column(:ability) do |record|
      status_tag(record.ability, record.can? ? :ok : nil)
    end
    column :action
    column :name
    column :class_name
  end
end
