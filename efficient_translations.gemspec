# -*- encoding: utf-8 -*-
if RUBY_VERSION == '1.8.7'
  $:.unshift File.expand_path("../lib", __FILE__)
  require "efficient_translations/version"
else
  # ruby 1.9
  require File.expand_path('../lib/efficient_translations/version', __FILE__)
end

Gem::Specification.new do |gem|
  gem.authors       = ['Nicola Racco']
  gem.email         = ['nicola@nicolaracco.com']
  gem.description   = %q{Translation library for ActiveRecord models in Rails 2}
  gem.summary       = %q{Translation library for ActiveRecord models in Rails 2 with an eye on performances}
  gem.homepage      = ''

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'sqlite3'
  gem.add_dependency 'activerecord' , '~> 2.3'
  gem.add_dependency 'activesupport', '~> 2.3'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "efficient_translations"
  gem.require_paths = ["lib"]
  gem.version       = EfficientTranslations::VERSION
end
