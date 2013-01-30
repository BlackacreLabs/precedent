source 'https://rubygems.org'

# Specify your gem's dependencies in precedent.gemspec
gemspec

group :development do
  # guard-rspec does not play nice with later versions of rb-inotify
  gem 'rb-inotify', '0.8.8', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
end
