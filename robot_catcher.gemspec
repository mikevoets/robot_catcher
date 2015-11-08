$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "robot_catcher/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "robot_catcher"
  s.version     = RobotCatcher::VERSION
  s.authors     = ["Maikovich"]
  s.email       = ["febrisnorvegia@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of RobotCatcher."
  s.description = "TODO: Description of RobotCatcher."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.3"

  s.add_development_dependency "sqlite3"
end
