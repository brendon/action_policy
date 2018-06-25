# frozen_string_literal: true

module ActionPolicy
  module Policy
    # Adds rules aliases support and ability to specify
    # the default rule.
    #
    #   class ApplicationPolicy
    #     include ActionPolicy::Policy::Core
    #     include ActionPolicy::Policy::Aliases
    #
    #     # define which rule to use if `authorize!` called with
    #     # unknown rule
    #     default_rule :manage?
    #
    #     alias_rule :publish?, :unpublish?, to: :update?
    #   end
    #
    # Aliases are used only during `authorize!` call (and do not act like _real_ aliases).
    #
    # Aliases useful when combined with `CachedApply` (since we can cache only the target rule).
    module Aliases
      DEFAULT = :__default__

      class << self
        def included(base)
          base.extend ClassMethods
        end
      end

      def resolve_rule(activity)
        if self.class.instance_methods(false).include?(activity)
          activity
        elsif self.class.lookup_alias(activity)
          self.class.lookup_alias(activity)
        elsif self.class.superclass.instance_methods.include?(activity)
          activity
        else
          self.class.lookup_default_rule || super
        end
      end

      module ClassMethods # :nodoc:
        def default_rule(val)
          rules_aliases[DEFAULT] = val
        end

        def alias_rule(*rules, to:)
          rules.each do |rule|
            rules_aliases[rule] = to
          end
        end

        def lookup_alias(rule)
          rules_aliases[rule]
        end

        def lookup_default_rule
          rules_aliases[DEFAULT]
        end

        def rules_aliases
          return @rules_aliases if instance_variable_defined?(:@rules_aliases)

          @rules_aliases =
            if superclass.respond_to?(:rules_aliases)
              superclass.rules_aliases.dup
            else
              {}
            end
        end
      end
    end
  end
end
