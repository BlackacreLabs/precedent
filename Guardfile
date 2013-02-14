guard :bundler do
  watch("precedent.gemspec")
end

require './lib/precedent/treetop_patch.rb'
guard :treetop do
  watch('**/*.treetop')
end

guard :rspec, bundler: false do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})
end
