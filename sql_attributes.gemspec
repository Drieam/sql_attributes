# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'sql_attributes/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'sql_attributes'
  spec.version     = SqlAttributes::VERSION
  spec.authors     = ['Stef Schenkelaars']
  spec.email       = ['stef.schenkelaars@gmail.com']
  spec.homepage    = 'https://drieam.github.io/sql_attributes'
  spec.summary     = <<~MESSAGE
    Add virtual attributes to an ActiveRecord model based on an SQL query.
  MESSAGE
  spec.description = spec.summary
  spec.license     = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Drieam/sql_attributes'

  spec.files = Dir['lib/**/*', 'LICENSE', 'README.md']

  spec.add_dependency 'activerecord', '>= 6.0.3'                   # Depend on activerecord as ORM

  spec.add_development_dependency 'combustion'                     # Test rails engines
  spec.add_development_dependency 'database_cleaner-active_record' # Ensure clean state for testing
  spec.add_development_dependency 'rspec-github'                   # RSpec formatter for GitHub Actions
  spec.add_development_dependency 'rspec-rails'                    # Testing framework
  spec.add_development_dependency 'rubocop'                        # Linter
  spec.add_development_dependency 'rubocop-performance'            # Linter for Performance optimization analysis
  spec.add_development_dependency 'rubocop-rails'                  # Linter for Rails-specific analysis
  spec.add_development_dependency 'sqlite3'                        # Database adapter
end
