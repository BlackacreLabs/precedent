require 'treetop/runtime'

# Syntax Nodes
require_relative 'grammar/nodes'
require_relative 'grammar/node_patch'

# Generated Grammars
require_relative 'grammar/inline.rb'
require_relative 'grammar/paragraph.rb'
require_relative 'grammar/heading.rb'
require_relative 'grammar/meta.rb'
require_relative 'grammar/document.rb'

module Precedent
  # Keep a single module-level instance of the generated parser.
  @@parser = DocumentParser.new

  # Programmatic interface to the Treetop-generated parsers.
  def self.parse(input)
    tree = @@parser.parse(input)
    if tree.nil?
      raise Exception,
        "Parse error at offset: #{@@parser.index} " +
        "#{@@parser.failure_reason}"
    end
    tree.build
  end
end
