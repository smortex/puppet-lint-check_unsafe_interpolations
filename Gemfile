source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gemspec

group :release do
  gem 'github_changelog_generator', require: false
end

group :coverage, optional: ENV['COVERAGE']!='yes' do
  gem 'simplecov-console', :require => false
  gem 'codecov', :require => false
end

group :rubocop do
  gem 'rubocop', '~> 1.6.1', require: false
  gem 'rubocop-rspec', '~> 2.0.1', require: false
  gem 'rubocop-performance', '~> 1.9.1', require: false
end

group :acceptance do
  gem 'puppet_litmus'
end

group :development do
  gem 'puppetlabs_spec_helper'
  gem 'rspec-puppet'
  gem 'rspec', '~> 3.0'
  gem 'rspec-its', '~> 1.0'
  gem 'rspec-collection_matchers', '~> 1.0'
  gem 'simplecov'
  gem 'rake'
end
