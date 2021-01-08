$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "teacherseat_permissions/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "teacherseat-permissions"
  s.version     = TeacherseatPermissions::VERSION
  s.authors     = ["TeacherSeat"]
  s.email       = ["andrew@teacherseat.com"]
  s.homepage    = "https://www.teacherseat.com"
  s.summary     = 'Teacherseat Permissions'
  s.description = 'Teacherseat Permissions'
  s.license     = "MIT"

  s.files = Dir["{lib}/**/**/*", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec'
end
