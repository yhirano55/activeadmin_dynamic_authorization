module Permission
  module Preparable
    extend ActiveSupport::Concern

    ACTION_DICTIONARY = HashWithIndifferentAccess.new(
      index:   :read,
      show:    :read,
      new:     :create,
      create:  :create,
      edit:    :update,
      update:  :update,
      destroy: :destroy,
    )

    class_methods do
      def reload
        transaction do
          clear_cache
          update_resources
          update_policies
          cleanup_resources
        end
      end

      private

      def clear_cache
        @_admin_resources = nil
      end

      def update_resources
        admin_resources.map &method(:find_or_create_by!)
      end

      def update_policies
        all.each do |resource|
          Policy.configurable_roles.keys.each do |role|
            Policy.find_or_create_by!(resource: resource, role: role)
          end
        end
      end

      def cleanup_resources
        (persisted_resources - admin_resources).each &method(:destroy_all)
      end

      def admin_resources
        @_admin_resources ||= begin
          active_admin_resources.inject([]) do |result, resource|
            name       = resource.resource_name.name
            class_name = resource.controller.resource_class.to_s
            actions    = collect_defined_actions(resource)

            result += eval_cancan_actions(actions).map(&:to_s).sort.map do |action|
              { name: name, class_name: class_name, action: action }
            end
          end
        end
      end

      def persisted_resources
        all.map(&:attributes).map { |h| h.slice("name", "class_name", "action").symbolize_keys }
      end

      def active_admin_resources
        ::ActiveAdmin.application.namespaces[:admin].resources
      end

      def collect_defined_actions(resource)
        if resource.respond_to?(:defined_actions)
          defined_actions    = resource.defined_actions
          member_actions     = resource.member_actions.map(&:name)
          collection_actions = resource.collection_actions.map(&:name)
          batch_actions      = resource.batch_actions_enabled? ? [:batch_action] : []

          defined_actions | member_actions | member_actions | collection_actions | batch_actions
        else
          resource.page_actions.map(&:name) | [:index]
        end
      end

      def eval_cancan_actions(actions)
        actions.inject(Set.new) do |result, action|
          result << (ACTION_DICTIONARY[action] || action)
        end
      end
    end
  end
end
