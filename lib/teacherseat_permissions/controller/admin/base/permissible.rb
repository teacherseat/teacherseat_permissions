require 'teacherseat_permissions/error/denied'

module TeacherseatPermissions
  module Controller
    module Admin
      module Base
        module Permissible
          extend ActiveSupport::Concern

          included do
            rescue_from TeacherseatPermissions::Error::StaticDenied, with: :static_permission_denied
            before_action :switch_tenant,
                          :admin_access_required
          end
          
          def switch_tenant
            tenant =
            if request.domain == ENV['PRIMARY_DOMAIN'] && request.subdomain.match(/\.app$/)
              TsAdminTen::Tenant.find_by(subdomain: "#{request.subdomain.sub(/\.app$/,'')}")
            else
              TsAdminTen::Tenant.find_by(customdomain: request.host)
            end
            unless tenant
              render file: "#{Rails.root}/public/404.html",  layout: false, status: :not_found
              return
            end
          end

          def admin_access_required
            unless logged_in?
              return(redirect_to "#{ENV['STUDENT_MOUNT_PATH']}/auth/login", status: 302)
            end
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

