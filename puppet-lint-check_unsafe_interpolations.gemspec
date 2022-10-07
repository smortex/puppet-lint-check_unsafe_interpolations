require_relative 'lib/puppet/lint/check_unsafe_interpolations/version'

Gem::Specification.new do |spec|
  spec.name          = "puppet-lint-check_unsafe_interpolations"
  spec.version       = '0.0.1'
  spec.authors       = ['Puppet, Inc.']
  spec.files         = Dir[
    'README.md',
    'LICENSE',
    'lib/**/*',
    'spec/**/*',
  ]
  spec.summary       = 'A puppet-lint plugin to check for unsafe interpolations.'
  spec.description   = <<-EOF
    A puppet-lint plugin to check for unsafe interpolations.
  EOF
  spec.homepage      = 'https://github.com/puppetlabs/puppet-lint-check_unsafe_interpolations'
  spec.license       = 'Apache-2.0'
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7".freeze)

  spec.add_dependency             'puppet-lint', '>= 1.0', '< 3.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.0'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'rake'
end
