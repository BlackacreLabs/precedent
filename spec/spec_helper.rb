if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.adapters.define('precedent') do
    add_filter '/spec/'
    add_filter '/grammar/'

    add_group 'Binaries', '/bin/'
    add_group 'Libraries', '/lib/'
  end

  SimpleCov.start('precedent')
end
