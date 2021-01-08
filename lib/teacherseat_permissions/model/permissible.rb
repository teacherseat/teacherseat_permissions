module TeacherseatPermissions
  module Model
    module Permissible
      extend ActiveSupport::Concern

      def admin?
        self.access_admin?
      end

      def permission? permission, conditions={}
        provider, namespace, system, subsystem, action = permission.downcase.split(':')

        result = self.permissions_tree
          .try('[]',provider)
          .try('[]',namespace)
          .try('[]',system)
          .try('[]',subsystem)
          .try('[]',action)

        if result
          # if there are conditions process them
          if result['condition'] && conditions != :ignore
            conditions.stringify_keys!
            result['effect'] == 'allow' &&
            result['condition'].all?{ |k,v|
              if conditions.key?(k)
                if v.is_a?(Array)
                  v.include?(conditions[k])
                elsif
                  conditions[k] == v
                else
                  false
                end
              else
                false
              end
            }
          else
            result['effect'] == 'allow'
          end
        else
          false
        end
      end

      # get the permission
      def permission permission
        provider, namespace, system, subsystem, action = permission.downcase.split(':')

        result = self.permissions_tree
          .try('[]',provider)
          .try('[]',namespace)
          .try('[]',system)
          .try('[]',subsystem)
          .try('[]',action)
      end
    end # Permissible
  end # Model
end # Teacherseat
