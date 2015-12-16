# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'radiant-custom_fields-extension'

Gem::Specification.new do |s|
  s.name        = 'radiant-custom_fields-extension'
  s.version     = RadiantCustomFieldsExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = RadiantCustomFieldsExtension::AUTHORS
  s.email       = RadiantCustomFieldsExtension::EMAIL
  s.homepage    = RadiantCustomFieldsExtension::URL
  s.summary     = RadiantCustomFieldsExtension::SUMMARY
  s.description = RadiantCustomFieldsExtension::DESCRIPTION
  
  # TODO: add gem dependency on this instead of bundling it
  # s.add_dependency 'has_many_polymorphs'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features,vendor/plugins/*/test,vendor/plugins/*/spec,vendor/plugins/*/features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  # TODO: update for usage with Bundler/Gemfile once Radiant gets that capability
  s.post_install_message = %{
  Add this to your radiant project by adding the following line to your environment.rb:
    config.gem 'radiant-custom_fields-extension', :version => '#{RadiantCustomFieldsExtension::VERSION}'
  }
end
