require 'teacherseat_permissions/error/denied'

module TeacherseatPermissions
  module Controller
    module Admin
      module Base
        module Permissible
          extend ActiveSupport::Concern

          included do
            rescue_from TeacherseatPermissions::Error::StaticDenied, with: :static_permission_denied
            before_action :admin_access_required,
                          :switch_tenant
          end

          def switch_tenant
            TsAdminTen::Tenant.set_tenant_id(_user.tenant_id)
          end

          def admin_access_required
            unless _user.admin?
              raise TeacherseatPermissions::Error::StaticDenied.new(nil,'AdminAccess',nil)
            end
          end

          def permission_required name
            permission = _user.permission(name)
            if permission && permission['effect'] == 'allow'
              return permission
            else
              raise TeacherseatPermissions::Error::StaticDenied.new(nil,name,nil)
            end
          end

          def static_permission_denied ex
            qs = []
            qs.push "permission=#{ex.permission}"
            qs.push "condition=#{ex.condition}"
            return(redirect_to "#{ENV['ADMIN_MOUNT_URL']}/access_denied?#{qs.join('&')}", status: 302)
          end
        end # Permissible
      end # Base
  end # Admin
  end # Controller
end # Teacherseat

