module Permission
  class Ability
    include CanCan::Ability

    def initialize(user)
      user ||= AdminUser.new

      if user.admin?
        can(:manage, :all)
      else
        policies = Policy.indexed_cache[user.role] || []
        policies.select(&:active?).map(&:condition).each { |cond| send(*cond) }

        # NOTE: for avoiding unexpected accident
        can(:read, ActiveAdmin::Page, name: "Dashboard")
      end
    end
  end
end
