require 'teacherseat_permissions/error/denied'

module TeacherseatPermissions
  module Controller
    module Permissible
      extend ActiveSupport::Concern

      included do
        rescue_from TeacherseatPermissions::Error::Denied, with: :permission_denied
      end

      def permission_required name
        permission = _user.permission(name)
        if permission && permission['effect'] == 'allow'
          return permission
        else
          raise TeacherseatPermissions::Error::Denied.new(nil,name,nil)
        end
      end

      def permission_denied ex
        qs = []
        qs.push "permission=#{ex.permission}"
        qs.push "condition=#{ex.condition}"
        return render(json: {redirect_to: "/section31/access_denied?#{qs.join('&')}"}, status: 403)
      end
    end
  end # Controller
end # Teacherseat
