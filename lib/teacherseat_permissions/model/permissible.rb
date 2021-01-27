module TeacherseatPermissions
  module Model
    module Permissible
      extend ActiveSupport::Concern

      def admin?
        self.access_admin?
      end

      def permission? permission, conditions={}
        logger.debug "permission?: #{permission} #{conditions.to_json}"
        provider, namespace, system, subsystem, action = permission.downcase.split(':')
        logger.debug "permission?: provider: #{provider} namespace: #{namespace} system: #{system} subsystem: #{subsystem} action: #{action}"

        result = self.permissions_tree
          .try('[]',provider)
          .try('[]',namespace)
          .try('[]',system)
          .try('[]',subsystem)
          .try('[]',action)
        logger.debug("result: #{result.inspect}")

        if result
          # if there are conditions process them
          if result['condition'] && conditions != :ignore
            logger.debug("checking condition")
            conditions.stringify_keys!
            result['effect'] == 'allow' &&
            result['condition'].all?{ |k,v|
              if conditions.key?(k)
                if v.is_a?(Array)
                  logger.debug("condition key array")
                  v.include?(conditions[k])
                elsif conditions[k].to_s == v.to_s
                  logger.debug("condition string array")
                  true
                elsif
                  logger.debug("condition not match : return false")
                  false
                end
              else
                logger.debug("no condition key: return false")
                false
              end
            }
          else
            logger.debug("no condition to check")
            logger.debug("return: #{result['effect'] == 'allow'}")
            result['effect'] == 'allow'
          end
        else
            logger.debug("return false")
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
