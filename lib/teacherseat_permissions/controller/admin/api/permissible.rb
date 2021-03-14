require 'teacherseat_permissions/error/denied'

module TeacherseatPermissions
  module Controller
    module Admin
      module Api
        module Permissible
          extend ActiveSupport::Concern

          included do
            rescue_from TeacherseatPermissions::Error::ApiDenied, with: :api_permission_denied
            before_action :switch_tenant,
                          :admin_api_access_required
          end

          def switch_tenant
            TsAdminTen::Tenant.set_tenant_id(_user.tenant_id)
          end

          def admin_api_access_required
            unless _user.admin?
              raise TeacherseatPermissions::Error::ApiDenied.new(nil,'AdminAccess',nil)
            end
          end

          def permission_required name
            permission = _user.permission(name)
            if permission && permission['effect'] == 'allow'
              return permission
            else
              raise TeacherseatPermissions::Error::ApiDenied.new(nil,name,nil)
            end
          end

          def api_permission_denied ex
            qs = []
            qs.push "permission=#{ex.permission}"
            qs.push "condition=#{ex.condition}"
            return render(json: {redirect_to: "#{ENV['ADMIN_MOUNT_URL']}/access_denied?#{qs.join('&')}"}, status: 403)
          end
        end # Permissible
      end # Api
    end # Admin
  end # Controller
end # Teacherseat
