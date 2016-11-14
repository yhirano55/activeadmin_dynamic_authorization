module Permission
  class Policy < ApplicationRecord
    include Manageable

    enum ability: { cannot: 0, can: 1 }

    belongs_to :resource

    delegate :name, :class_name, :action, :const, :options, :active?, to: :resource
    delegate :clear_cache, to: :class

    before_save :clear_cache

    with_options presence: true do
      validates :resource
      validates :role
      validates :ability
    end

    def condition
      [ability, action.to_sym, const, options]
    end

    concerning :Cacheable do
      class_methods do
        def indexed_cache
          @_indexed_cache ||= eager_load(:resource).all.group_by(&:role)
        end

        def clear_cache
          @_indexed_cache = nil
        end
      end
    end
  end
end
