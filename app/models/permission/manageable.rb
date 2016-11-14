module Permission
  module Manageable
    extend ActiveSupport::Concern

    included do
      enum role: { guest: 0, staff: 1, manager: 2, admin: 3 }
    end

    class_methods do
      def configurable_roles
        roles.except("admin")
      end
    end
  end
end
