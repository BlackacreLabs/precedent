require 'treetop/runtime'

require_relative 'precedent/version'
require_relative 'precedent/translator'

module Precedent
  def self.new(input)
    Translator.new(input)
  end
end
