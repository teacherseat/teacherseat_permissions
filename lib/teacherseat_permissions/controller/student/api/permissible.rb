module TeacherseatPermissions
  module Controller
    module Student
      module Api
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
              render json: {redirect_to: '/404.html'}, staus: :not_found
              return
            end
            if logged_in? && _user.tenant_id != tenant.id
              logout_killing_session!
              render json: {redirect_to: '/'}
              return
            end
            TsAdminTen::Tenant.set_tenant_id(tenant.id)
          end
        end # Permissible
      end # Api
    end # Admin
  end # Controller
end # Teacherseat
