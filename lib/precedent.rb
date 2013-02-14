require 'treetop/runtime'

%w{
  nodes node_patch
  inline heading paragraph meta document
}.each { |base| require_relative "precedent/grammar/#{base}.rb" }

require_relative 'precedent/version'
require_relative 'precedent/translator'

module Precedent
  def self.new(input)
    Translator.new(input)
  end
end
