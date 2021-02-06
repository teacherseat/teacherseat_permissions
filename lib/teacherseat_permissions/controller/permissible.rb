require 'teacherseat_permissions/error/denied'
require 'teacherseat_permissions/error/denied'

module TeacherseatPermissions
  module Controller
    module Permissible
      extend ActiveSupport::Concern

      included do
        rescue_from TeacherseatPermissions::Error::ApiDenied, with: :api_permission_denied
        rescue_from TeacherseatPermissions::Error::StaticDenied, with: :static_permission_denied
      end

      def permission_required name, format=:json
        permission = _user.permission(name)
        if permission && permission['effect'] == 'allow'
          return permission
        else
          if format == :json
            raise TeacherseatPermissions::Error::ApiDenied.new(nil,name,nil)
          else
            raise TeacherseatPermissions::Error::StaticDenied.new(nil,name,nil)
          end
        end
      end

      def static_permission_denied ex
        qs = []
        qs.push "permission=#{ex.permission}"
        qs.push "condition=#{ex.condition}"
        return(redirect_to "#{ENV['ADMIN_MOUNT_URL']}/access_denied?#{qs.join('&')}", status: 403)
      end

      def api_permission_denied ex
        qs = []
        qs.push "permission=#{ex.permission}"
        qs.push "condition=#{ex.condition}"
        return render(json: {redirect_to: "#{ENV['ADMIN_MOUNT_URL']}/access_denied?#{qs.join('&')}"}, status: 403)
      end
    end
  end # Controller
end # Teacherseat
