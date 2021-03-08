module TeacherseatPermissions
  module Controller
    module Student
      module Base
        module Permissible
          extend ActiveSupport::Concern

          included do
            before_action :switch_tenant
          end

          def switch_tenant
            tenant =
            if request.domain == ENV['PRIMARY_DOMAIN'] && request.subdomain.match(/-app$/)
              TsAdminTen::Tenant.find_by(subdomain: "#{request.subdomain.sub(/-app$/,'')}")
            else
              TsAdminTen::Tenant.find_by(customdomain: request.host)
            end
            unless tenant
              render file: "#{Rails.root}/public/404.html",  layout: false, status: :not_found
              return
            end
            if logged_in? && _user.tenant_id != tenant.id
              logout_killing_session!
              redirect_to '/'
              return
            end
            TsAdminTen::Tenant.set_tenant_id(tenant.id)
          end
        end # Permissible
      end # Api
    end # Admin
  end # Controller
end # Teacherseat

