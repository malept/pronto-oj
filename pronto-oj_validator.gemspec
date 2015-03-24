# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'pronto/oj_validator/version'

Gem::Specification.new do |s|
  s.name = 'pronto-oj_validator'
  s.version = Pronto::OJ_VALIDATOR_VERSION
  s.platform = Gem::Platform::RUBY
  s.author = 'Mark Lee'
  s.email = 'pronto+oj@lazymalevolence.com'
  s.homepage = 'http://github.org/malept/pronto-oj_validator'
  s.summary = 'Pronto runner for validating JSON via Oj'

  s.required_rubygems_version = '>= 1.3.6'
  s.license = 'MIT'

  s.files = Dir.glob('{lib}/**/*') + %w(LICENSE README.md)
  s.require_paths = ['lib']

  s.add_dependency 'pronto', '~> 0.4.0'
  s.add_dependency 'oj'
  s.add_development_dependency 'rake', '~> 10.3'
end
