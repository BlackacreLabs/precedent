# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'precedent/version'

Gem::Specification.new do |gem|
  gem.name          = "precedent"
  gem.version       = Precedent::VERSION
  gem.authors       = ["Kyle Mitchell"]
  gem.email         = ["kyleevanmitchell@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "treetop"

  gem.add_development_dependency 'awesome_print'
  gem.add_development_dependency 'faker'
  gem.add_development_dependency 'guard-bundler'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rb-inotify', "0.8.8"
  gem.add_development_dependency 'rspec', "~>2.12.0"
end
