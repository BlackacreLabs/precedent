# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'precedent/version'

Gem::Specification.new do |gem|
  gem.name          = "precedent"
  gem.version       = Precedent::VERSION
  gem.authors       = ["Kyle Mitchell"]
  gem.email         = ["kyle@blackacrelabs.org"]
  gem.description   = <<-eof
    Precedent is a lightweight markup language for legal documents
    heavily inspired by Markdown, LaTeX, and the print style of the
    United States Reports, the official reports of decisions of the
    United States Supreme Court.
  eof
  gem.summary       = %q{Markdown-esque markup for legal documents}
  gem.homepage      = "https://github.com/BlackacreLabs/precedent"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{
    |f| File.basename(f)
  }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "active_support", "~>3.0.0"
  gem.add_dependency "nokogiri", "~>1.5.6"
  gem.add_dependency "thor", "~>0.16.0"
  gem.add_dependency "treetop", "~>1.4.12"
  gem.add_dependency "xml-simple", "~>1.1.2"

  gem.add_development_dependency 'awesome_print'
  gem.add_development_dependency 'faker'
  gem.add_development_dependency 'guard-bundler'
  gem.add_development_dependency 'guard-rspec'
  # guard-rspec does not play nice with later versions of rb-inotify
  gem.add_development_dependency 'rb-inotify', "0.8.8"
  gem.add_development_dependency 'rspec', "~>2.12.0"
end
