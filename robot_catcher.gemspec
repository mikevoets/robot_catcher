$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "robot_catcher/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "robot_catcher"
  s.version     = RobotCatcher::VERSION
  s.authors     = ["Mike Voets"]
  s.email       = ["mwhg.voets@gmail.com"]
  s.summary     = "Form plugin for catching of bots."
  s.description = "RobotCatcher is a small form plugin that uses several kinds of hashing to consider whether a form has been filled out by a bot or a human being. "
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.3"

  s.add_development_dependency "sqlite3"
end
