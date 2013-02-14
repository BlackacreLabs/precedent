guard :bundler do
  watch("precedent.gemspec")
end

require './lib/precedent/treetop_patch.rb'
guard :treetop do
  watch('**/*.treetop')
end

guard :rspec, :spec_paths => ['spec'] do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m|
    "spec/lib/#{m[1]}_spec.rb"
  }
  watch(%r{^lib/precedent/(nodes|node_patch)\.rb$}) { |m|
    "spec/lib/precedent/parser_spec.rb"
  }
end
