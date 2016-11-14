module Permission
  class Resource < ApplicationRecord
    include Preparable

    has_many :policies, dependent: :destroy

    with_options presence: true do
      validates :name
      validates :class_name
      validates :action
    end

    def const
      @_const ||= class_name.safe_constantize
    end

    def active?
      !const.nil?
    end

    def options
      for_active_admin_page? ? { name: name } : {}
    end

    private

    def for_active_admin_page?
      const == ActiveAdmin::Page
    end
  end
end
