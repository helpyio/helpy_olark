$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "helpy_olark/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "helpy_olark"
  s.version     = HelpyOlark::VERSION
  s.authors     = ["Scott Miller"]
  s.email       = ["hello@scottmiller.io"]
  s.homepage    = "http://helpy.io"
  s.summary     = "Add an webhook for Olark to integrate with."
  s.description = "This extension creates an integration point for Olark to POST chat transcripts to and creates a ticket."
  s.license     = "MIT."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.7"
  s.add_dependency "deface"

  s.add_development_dependency "sqlite3"
end
