module TeacherseatPermissions
  module Model
    module Permissible
      extend ActiveSupport::Concern

      def admin?
        admin = TsAdminIam::Admin.find_by(user_id: self.id)
        admin && admin.access_admin
      end

      def permission? permission, conditions={}
        tslogger = Logger.new Rails.root.join('log','teacherseat_permissions.log')
        tslogger.level = Logger::DEBUG


        tslogger.debug "permission?: #{permission} #{conditions.to_json}"
        provider, namespace, system, subsystem, action = permission.downcase.split(':')
        tslogger.debug "permission?: provider: #{provider} namespace: #{namespace} system: #{system} subsystem: #{subsystem} action: #{action}"

        user = TsAdminIam::Admin.find_by(user_id: self.id)
        result = user.permissions_tree
          .try('[]',provider)
          .try('[]',namespace)
          .try('[]',system)
          .try('[]',subsystem)
          .try('[]',action)
        tslogger.debug("result: #{result.inspect}")

        if result
          # if there are conditions process them
          if result['condition'] && conditions != :ignore
            tslogger.debug("checking condition")
            conditions.stringify_keys!
            result['effect'] == 'allow' &&
            result['condition'].all?{ |k,v|
              if conditions.key?(k)
                if v.is_a?(Array)
                  tslogger.debug("condition key array")
                  v.include?(conditions[k])
                elsif conditions[k].to_s == v.to_s
                  tslogger.debug("condition string array")
                  true
                elsif
                  tslogger.debug("condition not match : return false")
                  false
                end
              else
                tslogger.debug("no condition key: return false")
                false
              end
            }
          else
            tslogger.debug("no condition to check")
            tslogger.debug("return: #{result['effect'] == 'allow'}")
            result['effect'] == 'allow'
          end
        else
            tslogger.debug("return false")
          false
        end
      end

      # get the permission
      def permission permission
        provider, namespace, system, subsystem, action = permission.downcase.split(':')

        user = TsAdminIam::Admin.find_by(user_id: self.id)
        result = user.permissions_tree
          .try('[]',provider)
          .try('[]',namespace)
          .try('[]',system)
          .try('[]',subsystem)
          .try('[]',action)
      end
    end # Permissible
  end # Model
end # Teacherseat
